"use client";

import React, { useState, useRef, useEffect } from "react";
import AppImage from "@/components/ui/appImage";
import ConfirmModal from "@/components/ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";
import { ChevronDown, ChevronUp, Upload, Bold, Italic, Underline, List, ListOrdered, Pencil, Trash2 } from "lucide-react";
import { useForm } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import * as yup from "yup";
import { useCreateTeamMemberMutation, useUpdateTeamMemberMutation, useDeleteTeamMemberMutation } from "@/store/api/teamApi";
import toast from "react-hot-toast";

type TeamMember = {
    id: string;
    name: string;
    role: string;
    image: string;
    content?: string;
};

interface TeamSidebarProps {
    heading: string;
    description: string;
    members: TeamMember[];
    onHeadingChange: (value: string) => void;
    onDescriptionChange: (value: string) => void;
    onMemberAdded?: () => void;
    isSaving?: boolean;
}

export default function TeamSidebar({
    heading,
    description,
    members,
    onHeadingChange,
    onDescriptionChange,
    onMemberAdded,
    isSaving = false,
}: TeamSidebarProps) {
    const [expandedMember, setExpandedMember] = useState<string | null>(members[0]?.id || null);
    const [isAddingNew, setIsAddingNew] = useState(false);
    const editorRef = useRef<HTMLDivElement>(null);
    const newMemberEditorRef = useRef<HTMLDivElement>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const memberFileInputRefs = useRef<Record<string, HTMLInputElement | null>>({});
    const saveTimeoutRefs = useRef<Record<string, NodeJS.Timeout>>({});
    const [memberData, setMemberData] = useState<Record<string, { name: string; role: string }>>({});
    const [newMemberData, setNewMemberData] = useState({ name: '', role: '', content: '', image: null as File | null });
    const [imagePreview, setImagePreview] = useState<string | null>(null);
    const [validationErrors, setValidationErrors] = useState<{ name?: string; role?: string; content?: string; image?: string }>({});
    const [savingMembers, setSavingMembers] = useState<Record<string, boolean>>({});
    const [createTeamMember, { isLoading: isCreating }] = useCreateTeamMemberMutation();
    const [updateTeamMember] = useUpdateTeamMemberMutation();
    const [deleteTeamMember, { isLoading: isDeletingMember }] = useDeleteTeamMemberMutation();

    const deleteConfirm = useDeleteConfirm<{ memberId: string; memberName: string }>({
        onDelete: (item) => deleteTeamMember(item.memberId).unwrap(),
        isDeleting: isDeletingMember,
        onSuccess: () => {
            toast.success("Team member deleted successfully!");
            onMemberAdded?.();
        },
    });

    // Initialize member data when members change
    useEffect(() => {
        const initialData: Record<string, { name: string; role: string }> = {};
        members.forEach(member => {
            initialData[member.id] = {
                name: member.name,
                role: member.role
            };
        });
        setMemberData(initialData);
    }, [members]);

    // Update editor content when expanded member changes (not on every content change)
    useEffect(() => {
        if (expandedMember && editorRef.current) {
            const member = members.find(m => m.id === expandedMember);
            if (member) {
                editorRef.current.innerHTML = member.content || '';
            }
        }
    }, [expandedMember, members]);

    // Cleanup timeouts on unmount
    useEffect(() => {
        return () => {
            Object.values(saveTimeoutRefs.current).forEach(timeout => clearTimeout(timeout));
        };
    }, []);

    const toggleMember = (id: string) => {
        setExpandedMember(expandedMember === id ? null : id);
        setIsAddingNew(false);
    };

    const autoSaveMember = async (memberId: string, field: 'name' | 'designation' | 'content', value?: string) => {
        // Clear existing timeout for this member
        if (saveTimeoutRefs.current[memberId]) {
            clearTimeout(saveTimeoutRefs.current[memberId]);
        }

        // Set new timeout for auto-save
        saveTimeoutRefs.current[memberId] = setTimeout(async () => {
            try {
                setSavingMembers(prev => ({ ...prev, [memberId]: true }));

                const formData = new FormData();
                const member = members.find(m => m.id === memberId);
                if (!member) return;

                // Get current content from editor DOM if saving content, otherwise get stored value
                let currentContent = member.content || '';
                if (field === 'content' && expandedMember === memberId && editorRef.current) {
                    currentContent = editorRef.current.innerHTML;
                }

                // Include all current data
                formData.append('name', field === 'name' ? value! : memberData[memberId]?.name || member.name);
                formData.append('designation', field === 'designation' ? value! : memberData[memberId]?.role || member.role);
                formData.append('content', currentContent);

                await updateTeamMember({ id: memberId, formData }).unwrap();

                setSavingMembers(prev => ({ ...prev, [memberId]: false }));
            } catch (error: any) {
                setSavingMembers(prev => ({ ...prev, [memberId]: false }));
                toast.error(error?.data?.message || "Failed to update team member");
            }
        }, 1000); // Save after 1 second of no typing
    };

    const handleAddMember = () => {
        setIsAddingNew(true);
        setExpandedMember(null);
        setNewMemberData({ name: '', role: '', content: '', image: null });
        setImagePreview(null);
        setValidationErrors({});
        setTimeout(() => {
            if (newMemberEditorRef.current) {
                newMemberEditorRef.current.innerHTML = '';
            }
        }, 0);
    };

    const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            setNewMemberData(prev => ({ ...prev, image: file }));
            const reader = new FileReader();
            reader.onloadend = () => {
                setImagePreview(reader.result as string);
            };
            reader.readAsDataURL(file);
            setValidationErrors(prev => ({ ...prev, image: undefined }));
        }
    };

    const handleSaveMember = async () => {
        // Validate all fields
        const errors: { name?: string; role?: string; content?: string; image?: string } = {};

        if (!newMemberData.name.trim()) {
            errors.name = "Name is required";
        }
        if (!newMemberData.role.trim()) {
            errors.role = "Role is required";
        }
        if (!newMemberData.content.trim()) {
            errors.content = "Description is required";
        }
        if (!newMemberData.image) {
            errors.image = "Image is required";
        }

        if (Object.keys(errors).length > 0) {
            setValidationErrors(errors);
            toast.error("Please fill in all required fields");
            return;
        }

        try {
            const formData = new FormData();
            formData.append("name", newMemberData.name);
            formData.append("designation", newMemberData.role);
            formData.append("content", newMemberData.content);
            if (newMemberData.image) {
                formData.append("image", newMemberData.image);
            }

            await createTeamMember(formData).unwrap();
            toast.success("Team member created successfully!");

            // Reset form
            setIsAddingNew(false);
            setNewMemberData({ name: '', role: '', content: '', image: null });
            setImagePreview(null);
            setValidationErrors({});

            // Notify parent to refetch data
            if (onMemberAdded) {
                onMemberAdded();
            }
        } catch (error: any) {
            toast.error(error?.data?.message || "Failed to create team member");
        }
    };

    const handleMemberFieldChange = (memberId: string, field: 'name' | 'role', value: string) => {
        setMemberData(prev => ({
            ...prev,
            [memberId]: {
                ...prev[memberId],
                [field]: value
            }
        }));
    };

    const handleContentChange = (memberId: string) => {
        // Content is stored in the DOM, no action needed
    };

    const handleSaveExistingMember = async (memberId: string) => {
        try {
            setSavingMembers(prev => ({ ...prev, [memberId]: true }));

            const formData = new FormData();
            const member = members.find(m => m.id === memberId);
            if (!member) return;

            // Get current content from editor DOM
            let currentContent = member.content || '';
            if (expandedMember === memberId && editorRef.current) {
                currentContent = editorRef.current.innerHTML;
            }

            // Include all current data
            formData.append('name', memberData[memberId]?.name || member.name);
            formData.append('designation', memberData[memberId]?.role || member.role);
            formData.append('content', currentContent);

            await updateTeamMember({ id: memberId, formData }).unwrap();
            toast.success("Team member updated successfully!");

            setSavingMembers(prev => ({ ...prev, [memberId]: false }));

            // Notify parent to refetch
            if (onMemberAdded) {
                onMemberAdded();
            }
        } catch (error: any) {
            setSavingMembers(prev => ({ ...prev, [memberId]: false }));
            toast.error(error?.data?.message || "Failed to update team member");
        }
    };

    const handleCancelEdit = (memberId: string) => {
        const member = members.find(m => m.id === memberId);
        if (!member) return;

        // Reset fields to original values
        setMemberData(prev => ({
            ...prev,
            [memberId]: {
                name: member.name,
                role: member.role
            }
        }));

        // Reset editor content
        if (expandedMember === memberId && editorRef.current) {
            editorRef.current.innerHTML = member.content || '';
        }

        // Collapse the member
        setExpandedMember(null);
    };

    const handleMemberImageUpdate = async (memberId: string, file: File) => {
        try {
            setSavingMembers(prev => ({ ...prev, [memberId]: true }));

            const member = members.find(m => m.id === memberId);
            if (!member) return;

            // Get current content from editor DOM if this member is expanded
            let currentContent = member.content || '';
            if (expandedMember === memberId && editorRef.current) {
                currentContent = editorRef.current.innerHTML;
            }

            const formData = new FormData();
            formData.append('name', memberData[memberId]?.name || member.name);
            formData.append('designation', memberData[memberId]?.role || member.role);
            formData.append('content', currentContent);
            formData.append('image', file);

            await updateTeamMember({ id: memberId, formData }).unwrap();
            toast.success("Image updated successfully!");

            setSavingMembers(prev => ({ ...prev, [memberId]: false }));

            // Notify parent to refetch
            if (onMemberAdded) {
                onMemberAdded();
            }
        } catch (error: any) {
            setSavingMembers(prev => ({ ...prev, [memberId]: false }));
            toast.error(error?.data?.message || "Failed to update image");
        }
    };

    const handleDeleteMember = (memberId: string, memberName: string, e: React.MouseEvent) => {
        e.stopPropagation();
        deleteConfirm.openDelete({ memberId, memberName });
    };

    const applyFormat = (command: string, value?: string) => {
        if (!editorRef.current) return;
        editorRef.current.focus();
        document.execCommand(command, false, value);
    };

    const applyHeading = (e: React.ChangeEvent<HTMLSelectElement>) => {
        const value = e.target.value;
        if (!editorRef.current) return;
        editorRef.current.focus();

        // Use the proper format for formatBlock
        document.execCommand('formatBlock', false, value);
    };

    return (
        <aside className="fixed right-0 top-0 w-72 3xl:w-75 h-screen bg-white border-l border-gray-200 hidden sm:flex flex-col">
            {/* Scrollable content */}
            <div className="flex-1 overflow-y-auto overflow-x-hidden">
                <div className="p-3 space-y-6">
                    {/* Header Section */}
                    <div>
                        <label className="block text-sm font-medium text-text-gray mt-12 3xl:mt-18 mb-2">
                            Heading
                        </label>
                        <input
                            type="text"
                            value={heading}
                            onChange={(e) => onHeadingChange(e.target.value)}
                            className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors"
                            placeholder="Enter heading"
                        />
                    </div>

                    {/* Description */}
                    <div>
                        <label className="block text-sm font-medium text-text-gray mb-2">
                            Description
                        </label>
                        <textarea
                            value={description}
                            onChange={(e) => onDescriptionChange(e.target.value)}
                            className="text-xs text-black leading-relaxed w-full border border-extra-light-gray rounded-sm p-3 focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none transition-colors resize-none"
                            rows={6}
                            placeholder="Enter description"
                        />
                    </div>

                    {/* Team Members Section */}
                    <div className="">
                        <div className="flex items-center justify-between py-4 border-t border-b border-gray-200 mx-2">
                            <h3 className="text-sm font-medium text-gray-700 text-nowrap">Team Members</h3>
                            <button
                                onClick={handleAddMember}
                                className="text-teal-500 text-sm font-medium hover:text-teal-600 cursor-pointer text-nowrap"
                            >
                                + Add Member
                            </button>
                        </div>

                        {/* New Member Form */}
                        {isAddingNew && (
                            <div className="border-b border-gray-200">
                                <div
                                    className="flex items-center justify-between px-6 py-3 bg-gray-50 cursor-pointer hover:bg-gray-100"
                                    onClick={() => setIsAddingNew(false)}
                                >
                                    <span className="text-sm font-medium text-gray-900">
                                        New Member
                                    </span>
                                    <div className="text-gray-600">
                                        <ChevronUp className="w-5 h-5" />
                                    </div>
                                </div>

                                {/* New Member Form Fields */}
                                <div className="px-2 py-2 space-y-4 bg-white">
                                    {/* Image Upload Area */}
                                    <div>
                                        <input
                                            ref={fileInputRef}
                                            type="file"
                                            accept="image/*"
                                            onChange={handleImageSelect}
                                            className="hidden"
                                        />
                                        <div
                                            onClick={() => fileInputRef.current?.click()}
                                            className={`relative bg-slate-gray rounded-lg overflow-hidden flex items-center justify-center w-38 h-44 border-2 border-dashed ${validationErrors.image ? 'border-red-500' : 'border-extra-light-gray'
                                                } cursor-pointer hover:bg-gray-100`}
                                        >
                                            {imagePreview ? (
                                                <AppImage
                                                    src={imagePreview}
                                                    alt="Preview"
                                                    width={200}
                                                    height={208}
                                                    className="w-38 h-44 object-contain"
                                                />
                                            ) : (
                                                <div className="flex items-center gap-2 px-4 py-2 text-xs font-medium text-gray-700 bg-white border border-extra-light-gray rounded-lg hover:bg-gray-50">
                                                    <Upload className="w-4 h-4" />
                                                    Upload
                                                </div>
                                            )}
                                        </div>
                                        {validationErrors.image && (
                                            <p className="text-red-500 text-xs mt-1">{validationErrors.image}</p>
                                        )}
                                    </div>

                                    {/* Name Field */}
                                    <div>
                                        <label className="block text-sm font-medium text-text-gray mb-2">
                                            Name <span className="text-red-500">*</span>
                                        </label>
                                        <input
                                            type="text"
                                            placeholder="Enter name"
                                            value={newMemberData.name}
                                            onChange={(e) => {
                                                setNewMemberData(prev => ({ ...prev, name: e.target.value }));
                                                setValidationErrors(prev => ({ ...prev, name: undefined }));
                                            }}
                                            className={`w-full px-3 py-2 text-xs border ${validationErrors.name ? 'border-red-500' : 'border-extra-light-gray'
                                                } rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none text-black`}
                                        />
                                        {validationErrors.name && (
                                            <p className="text-red-500 text-xs mt-1">{validationErrors.name}</p>
                                        )}
                                    </div>

                                    {/* Role Field */}
                                    <div>
                                        <label className="block text-sm font-medium text-text-gray mb-2">
                                            Role <span className="text-red-500">*</span>
                                        </label>
                                        <input
                                            type="text"
                                            placeholder="Enter role"
                                            value={newMemberData.role}
                                            onChange={(e) => {
                                                setNewMemberData(prev => ({ ...prev, role: e.target.value }));
                                                setValidationErrors(prev => ({ ...prev, role: undefined }));
                                            }}
                                            className={`w-full px-3 py-2 text-xs border ${validationErrors.role ? 'border-red-500' : 'border-extra-light-gray'
                                                } rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none text-black`}
                                        />
                                        {validationErrors.role && (
                                            <p className="text-red-500 text-xs mt-1">{validationErrors.role}</p>
                                        )}
                                    </div>

                                    {/* Description Field */}
                                    <div>
                                        <label className="block text-sm font-medium text-gray-700 mb-2">
                                            Description <span className="text-red-500">*</span>
                                        </label>
                                        <div className={`border ${validationErrors.content ? 'border-red-500' : 'border-gray-300'
                                            } rounded-lg overflow-hidden bg-white`}>
                                            {/* Toolbar */}
                                            <div className="flex items-center gap-2 px-3 py-2 border-b border-gray-200 bg-gray-50 flex-wrap">
                                                <select
                                                    onChange={(e) => {
                                                        const value = e.target.value;
                                                        if (!newMemberEditorRef.current) return;
                                                        newMemberEditorRef.current.focus();
                                                        document.execCommand('formatBlock', false, value);
                                                        // Reset select to default
                                                        e.target.value = '';
                                                    }}
                                                    className="text-xs border border-gray-300 rounded px-2 py-1 bg-white focus:outline-none text-gray-700"
                                                    value=""
                                                >
                                                    <option value="" disabled>Format</option>
                                                    <option value="p">Normal text</option>
                                                    <option value="h1">Heading 1</option>
                                                    <option value="h2">Heading 2</option>
                                                    <option value="h3">Heading 3</option>
                                                </select>

                                                <span className="text-gray-300">|</span>

                                                {/* List Buttons */}
                                                <div className="flex items-center gap-1">
                                                    <button
                                                        type="button"
                                                        onClick={() => {
                                                            if (!newMemberEditorRef.current) return;
                                                            newMemberEditorRef.current.focus();
                                                            document.execCommand('insertUnorderedList', false);
                                                        }}
                                                        className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                        title="Bullet List"
                                                    >
                                                        <List className="w-3.5 h-3.5" />
                                                    </button>
                                                    <button
                                                        type="button"
                                                        onClick={() => {
                                                            if (!newMemberEditorRef.current) return;
                                                            newMemberEditorRef.current.focus();
                                                            document.execCommand('insertOrderedList', false);
                                                        }}
                                                        className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                        title="Numbered List"
                                                    >
                                                        <ListOrdered className="w-3.5 h-3.5" />
                                                    </button>
                                                </div>

                                                <span className="text-gray-300">|</span>

                                                <div className="flex items-center gap-1">
                                                    <button
                                                        type="button"
                                                        onClick={() => {
                                                            if (!newMemberEditorRef.current) return;
                                                            newMemberEditorRef.current.focus();
                                                            document.execCommand('bold', false);
                                                        }}
                                                        className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                        title="Bold"
                                                    >
                                                        <Bold className="w-3.5 h-3.5" />
                                                    </button>
                                                    <button
                                                        type="button"
                                                        onClick={() => {
                                                            if (!newMemberEditorRef.current) return;
                                                            newMemberEditorRef.current.focus();
                                                            document.execCommand('italic', false);
                                                        }}
                                                        className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                        title="Italic"
                                                    >
                                                        <Italic className="w-3.5 h-3.5" />
                                                    </button>
                                                    <button
                                                        type="button"
                                                        onClick={() => {
                                                            if (!newMemberEditorRef.current) return;
                                                            newMemberEditorRef.current.focus();
                                                            document.execCommand('underline', false);
                                                        }}
                                                        className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                        title="Underline"
                                                    >
                                                        <Underline className="w-3.5 h-3.5" />
                                                    </button>
                                                    <button
                                                        type="button"
                                                        onClick={() => {
                                                            if (!newMemberEditorRef.current) return;
                                                            newMemberEditorRef.current.focus();
                                                            document.execCommand('strikeThrough', false);
                                                        }}
                                                        className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                        title="Strikethrough"
                                                    >
                                                        <span className="text-xs line-through font-bold">S</span>
                                                    </button>
                                                </div>

                                                <span className="text-gray-300">|</span>

                                                {/* Text Color */}
                                                <div className="relative">
                                                    <input
                                                        type="color"
                                                        onChange={(e) => {
                                                            if (!newMemberEditorRef.current) return;
                                                            newMemberEditorRef.current.focus();
                                                            document.execCommand('foreColor', false, e.target.value);
                                                        }}
                                                        className="w-8 h-6 border border-gray-300 rounded cursor-pointer"
                                                        title="Text Color"
                                                        defaultValue="#000000"
                                                    />
                                                </div>
                                            </div>

                                            {/* Rich Text Area */}
                                            <div
                                                ref={newMemberEditorRef}
                                                contentEditable
                                                className="w-full px-3 py-2 text-sm border-0 focus:outline-none min-h-[120px] max-h-[200px] overflow-y-auto rich-text-editor"
                                                suppressContentEditableWarning
                                                onInput={(e) => {
                                                    const content = e.currentTarget.innerHTML;
                                                    setNewMemberData(prev => ({ ...prev, content }));
                                                    setValidationErrors(prev => ({ ...prev, content: undefined }));
                                                }}
                                            />
                                        </div>
                                        {validationErrors.content && (
                                            <p className="text-red-500 text-xs mt-1">{validationErrors.content}</p>
                                        )}
                                    </div>

                                    {/* Action Buttons */}
                                    <div className="flex gap-2 pt-2">
                                        <button
                                            onClick={handleSaveMember}
                                            disabled={isCreating}
                                            className="flex-1 px-4 py-2 text-xs font-medium text-white bg-teal-500 rounded-lg hover:bg-teal-600 transition-colors cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
                                        >
                                            {isCreating ? 'Saving...' : 'Save Member'}
                                        </button>
                                        <button
                                            onClick={() => setIsAddingNew(false)}
                                            disabled={isCreating}
                                            className="flex-1 px-4 py-2 text-xs font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200
                                            cursor-pointer transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                                        >
                                            Cancel
                                        </button>
                                    </div>
                                </div>
                            </div>
                        )}

                        {/* Members List */}
                        <div className="space-y-0 px-2">
                            {members.map((member) => (
                                <div key={member.id} className="border-b border-gray-200">
                                    {/* Member Header */}
                                    <div
                                        className="flex items-center justify-between py-3 bg-white cursor-pointer hover:bg-gray-50"
                                        onClick={() => toggleMember(member.id)}
                                    >
                                        <span className="text-sm font-medium text-gray-900">
                                            {member.name}
                                        </span>
                                        <div className="flex items-center gap-2 text-gray-600">
                                            <button
                                                onClick={(e) => handleDeleteMember(member.id, member.name, e)}
                                                className="text-red-500 hover:text-red-600 transition-colors cursor-pointer"
                                                title="Delete member"
                                            >
                                                <Trash2 className="w-4 h-4" />
                                            </button>
                                            {expandedMember === member.id ? (
                                                <ChevronUp className="w-5 h-5" />
                                            ) : (
                                                <ChevronDown className="w-5 h-5" />
                                            )}
                                        </div>
                                    </div>

                                    {/* Expanded Form */}
                                    {expandedMember === member.id && (
                                        <div className="py-2 space-y-4 bg-white">
                                            {/* Image Preview Area */}
                                            <div>
                                                <input
                                                    ref={(el: any) => memberFileInputRefs.current[member.id] = el}
                                                    type="file"
                                                    accept="image/*"
                                                    onChange={(e) => {
                                                        const file = e.target.files?.[0];
                                                        if (file) {
                                                            handleMemberImageUpdate(member.id, file);
                                                        }
                                                    }}
                                                    className="hidden"
                                                />
                                                <div
                                                    onClick={() => memberFileInputRefs.current[member.id]?.click()}
                                                    className="relative bg-slate-gray rounded-lg overflow-hidden flex items-center justify-center w-38 h-44 border-2 border-dashed border-extra-light-gray group cursor-pointer"
                                                >
                                                    {member.image ? (
                                                        <>
                                                            {/* Blurred Background Image */}
                                                            <AppImage
                                                                src={member.image}
                                                                alt={`${member.name} background`}
                                                                width={200}
                                                                height={208}
                                                                className="absolute inset-0 w-full h-full object-cover blur-xl scale-110 opacity-30"
                                                            />
                                                            {/* Main Image */}
                                                            <AppImage
                                                                src={member.image}
                                                                alt={member.name}
                                                                width={200}
                                                                height={208}
                                                                className="relative w-full h-full object-contain"
                                                            />
                                                            {/* Hover Overlay */}
                                                            <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-all duration-300 z-10">
                                                                {/* Pencil Icon - Top Right */}
                                                                <div className="absolute top-3 right-3 text-white opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                                                                    <Pencil className="w-5 h-5" />
                                                                </div>
                                                                {/* Change Text - Center */}
                                                                <div className="absolute inset-0 flex items-center justify-center">
                                                                    <span className="text-white font-medium text-sm opacity-0 group-hover:opacity-100 transition-opacity duration-300">Change</span>
                                                                </div>
                                                            </div>
                                                        </>
                                                    ) : (
                                                        <div className="flex items-center gap-2 px-4 py-2 text-xs font-medium text-gray-700 bg-white border border-extra-light-gray rounded-lg hover:bg-gray-50">
                                                            <Upload className="w-4 h-4" />
                                                            Upload
                                                        </div>
                                                    )}
                                                </div>
                                            </div>

                                            {/* Name Field */}
                                            <div>
                                                <label className="block text-sm font-medium text-text-gray mb-2">
                                                    Name
                                                </label>
                                                <input
                                                    type="text"
                                                    placeholder="Enter name"
                                                    value={memberData[member.id]?.name || ''}
                                                    onChange={(e) => handleMemberFieldChange(member.id, 'name', e.target.value)}
                                                    className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none text-black"
                                                />
                                            </div>

                                            {/* Role Field */}
                                            <div>
                                                <label className="block text-sm font-medium text-text-gray mb-2">
                                                    Role
                                                </label>
                                                <input
                                                    type="text"
                                                    placeholder="Enter role"
                                                    value={memberData[member.id]?.role || ''}
                                                    onChange={(e) => handleMemberFieldChange(member.id, 'role', e.target.value)}
                                                    className="w-full px-3 py-2 text-xs border border-extra-light-gray rounded-sm focus:border-teal-500 focus:ring-1 focus:ring-teal-500 focus:outline-none text-black"
                                                />
                                            </div>

                                            {/* Description Field */}
                                            <div>
                                                <label className="block text-sm font-medium text-gray-700 mb-2">
                                                    Description
                                                </label>
                                                <div className="border border-gray-300 rounded-lg overflow-hidden bg-white">
                                                    {/* Toolbar */}
                                                    <div className="flex items-center gap-2 px-3 py-2 border-b border-gray-200 bg-gray-50 flex-wrap">
                                                        <select
                                                            onChange={applyHeading}
                                                            className="text-xs border border-gray-300 rounded px-2 py-1 bg-white focus:outline-none text-gray-700"
                                                            value=""
                                                        >
                                                            <option value="" disabled>Format</option>
                                                            <option value="p">Normal text</option>
                                                            <option value="h1">Heading 1</option>
                                                            <option value="h2">Heading 2</option>
                                                            <option value="h3">Heading 3</option>
                                                        </select>

                                                        <span className="text-gray-300">|</span>

                                                        {/* List Buttons */}
                                                        <div className="flex items-center gap-1">
                                                            <button
                                                                type="button"
                                                                onClick={() => applyFormat('insertUnorderedList')}
                                                                className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                                title="Bullet List"
                                                            >
                                                                <List className="w-3.5 h-3.5" />
                                                            </button>
                                                            <button
                                                                type="button"
                                                                onClick={() => applyFormat('insertOrderedList')}
                                                                className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                                title="Numbered List"
                                                            >
                                                                <ListOrdered className="w-3.5 h-3.5" />
                                                            </button>
                                                        </div>

                                                        <span className="text-gray-300">|</span>

                                                        <div className="flex items-center gap-1">
                                                            <button
                                                                type="button"
                                                                onClick={() => applyFormat('bold')}
                                                                className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                                title="Bold"
                                                            >
                                                                <Bold className="w-3.5 h-3.5" />
                                                            </button>
                                                            <button
                                                                type="button"
                                                                onClick={() => applyFormat('italic')}
                                                                className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                                title="Italic"
                                                            >
                                                                <Italic className="w-3.5 h-3.5" />
                                                            </button>
                                                            <button
                                                                type="button"
                                                                onClick={() => applyFormat('underline')}
                                                                className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                                title="Underline"
                                                            >
                                                                <Underline className="w-3.5 h-3.5" />
                                                            </button>
                                                            <button
                                                                type="button"
                                                                onClick={() => applyFormat('strikeThrough')}
                                                                className="p-1.5 hover:bg-gray-200 rounded text-gray-700 transition"
                                                                title="Strikethrough"
                                                            >
                                                                <span className="text-xs line-through font-bold">S</span>
                                                            </button>
                                                        </div>

                                                        <span className="text-gray-300">|</span>

                                                        {/* Text Color */}
                                                        <div className="relative">
                                                            <input
                                                                type="color"
                                                                onChange={(e) => applyFormat('foreColor', e.target.value)}
                                                                className="w-8 h-6 border border-gray-300 rounded cursor-pointer"
                                                                title="Text Color"
                                                                defaultValue="#000000"
                                                            />
                                                        </div>
                                                    </div>

                                                    {/* Rich Text Area */}
                                                    <div
                                                        ref={editorRef}
                                                        contentEditable
                                                        className="w-full px-3 py-2 text-sm border-0 focus:outline-none min-h-[120px] max-h-[200px] overflow-y-auto rich-text-editor"
                                                        suppressContentEditableWarning
                                                        onInput={() => {
                                                            handleContentChange(member.id);
                                                        }}
                                                        onMouseDown={(e) => {
                                                            // Prevent losing focus when clicking buttons
                                                            e.stopPropagation();
                                                        }}
                                                    />
                                                </div>
                                                <style jsx global>{`
                                                    .rich-text-editor:empty:before {
                                                        content: 'Enter Description';
                                                        color: #9ca3af;
                                                        pointer-events: none;
                                                    }
                                                    .rich-text-editor h1 {
                                                        font-size: 2rem !important;
                                                        font-weight: 700 !important;
                                                        line-height: 2.5rem !important;
                                                        margin: 0.75rem 0 !important;
                                                    }
                                                    .rich-text-editor h2 {
                                                        font-size: 1.5rem !important;
                                                        font-weight: 600 !important;
                                                        line-height: 2rem !important;
                                                        margin: 0.75rem 0 !important;
                                                    }
                                                    .rich-text-editor h3 {
                                                        font-size: 1.25rem !important;
                                                        font-weight: 600 !important;
                                                        line-height: 1.75rem !important;
                                                        margin: 0.75rem 0 !important;
                                                    }
                                                    .rich-text-editor p {
                                                        font-size: 0.875rem !important;
                                                        margin: 0.5rem 0 !important;
                                                    }
                                                    .rich-text-editor ul {
                                                        list-style-type: disc !important;
                                                        margin: 0.5rem 0 !important;
                                                        padding-left: 2rem !important;
                                                    }
                                                    .rich-text-editor ol {
                                                        list-style-type: decimal !important;
                                                        margin: 0.5rem 0 !important;
                                                        padding-left: 2rem !important;
                                                    }
                                                    .rich-text-editor li {
                                                        margin: 0.25rem 0 !important;
                                                        padding-left: 0.25rem !important;
                                                    }
                                                    .rich-text-editor ul li::marker {
                                                        color: #374151;
                                                    }
                                                    .rich-text-editor ol li::marker {
                                                        color: #374151;
                                                        font-weight: 500;
                                                    }
                                                `}</style>
                                            </div>

                                            {/* Action Buttons */}
                                            <div className="flex gap-2 pt-2">
                                                <button
                                                    onClick={() => handleSaveExistingMember(member.id)}
                                                    disabled={savingMembers[member.id]}
                                                    className="flex-1 px-4 py-2 text-xs font-medium text-white bg-teal-500 rounded-lg hover:bg-teal-600 transition-colors cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
                                                >
                                                    {savingMembers[member.id] ? 'Saving...' : 'Save Changes'}
                                                </button>
                                                <button
                                                    onClick={() => handleCancelEdit(member.id)}
                                                    disabled={savingMembers[member.id]}
                                                    className="flex-1 px-4 py-2 text-xs font-medium text-gray-700 bg-gray-100 rounded-lg hover:bg-gray-200 cursor-pointer transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
                                                >
                                                    Cancel
                                                </button>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>

            <ConfirmModal
                open={deleteConfirm.open}
                onOpenChange={deleteConfirm.onOpenChange}
                title="Delete Team Member"
                description={
                    deleteConfirm.deleteItem ? (
                        <>Are you sure you want to delete <strong>{deleteConfirm.deleteItem.memberName}</strong> member?</>
                    ) : null
                }
                error={deleteConfirm.deleteError}
                confirmText="Yes"
                cancelText="No"
                variant="danger"
                loading={isDeletingMember}
                onConfirm={deleteConfirm.onConfirm}
            />
        </aside>
    );
}
