"use client";

import React, { useRef } from "react";
import { ChevronDown, ChevronUp, Trash2, Upload, Pencil } from "lucide-react";
import AppImage from "@/components/ui/appImage";
import toast from "react-hot-toast";

interface TeamMember {
    id: string;
    image: string;
    imageId?: string;
    isExisting?: boolean;
}

interface TeamMembersSectionProps {
    teamMembers: TeamMember[];
    onTeamMembersChange: (members: TeamMember[]) => void;
    onFilesChange: (files: File[]) => void;
}

export default function TeamMembersSection({
    teamMembers,
    onTeamMembersChange,
    onFilesChange,
}: TeamMembersSectionProps) {
    const [expandedMember, setExpandedMember] = React.useState<string | null>(null);
    const teamMemberRefs = useRef<{ [key: string]: HTMLInputElement | null }>({});
    const [memberFiles, setMemberFiles] = React.useState<{ [key: string]: File }>({});

    const handleTeamMemberImageSelect = (
        memberId: string,
        e: React.ChangeEvent<HTMLInputElement>
    ) => {
        const file = e.target.files?.[0];
        if (file) {
            if (!file.type.startsWith("image/")) {
                toast.error("Please select an image file");
                return;
            }
            if (file.size > 5 * 1024 * 1024) {
                toast.error("Image size should be less than 5MB");
                return;
            }
            const reader = new FileReader();
            reader.onloadend = () => {
                const updatedMembers = teamMembers.map((member) =>
                    member.id === memberId
                        ? { ...member, image: reader.result as string }
                        : member
                );
                onTeamMembersChange(updatedMembers);

                // Update files
                const updatedFiles = { ...memberFiles, [memberId]: file };
                setMemberFiles(updatedFiles);
                onFilesChange(Object.values(updatedFiles));
            };
            reader.readAsDataURL(file);
        }
    };

    const addTeamMember = () => {
        const newMember: TeamMember = {
            id: `member-${Date.now()}`,
            image: "",
            isExisting: false,
        };
        onTeamMembersChange([...teamMembers, newMember]);
        setExpandedMember(newMember.id);
    };

    const removeTeamMember = (memberId: string) => {
        if (teamMembers.length === 1) {
            toast.error('At least one team member is required');
            return;
        }

        const updatedMembers = teamMembers.filter(
            (member) => member.id !== memberId
        );

        // Remove file for deleted member
        const updatedFiles = { ...memberFiles };
        delete updatedFiles[memberId];
        setMemberFiles(updatedFiles);

        if (expandedMember === memberId) {
            setExpandedMember(null);
        }

        // Update state
        onTeamMembersChange(updatedMembers);
        onFilesChange(Object.values(updatedFiles));
    };

    const toggleMember = (memberId: string) => {
        if (expandedMember === memberId) {
            setExpandedMember(null);
        } else {
            setExpandedMember(memberId);
        }
    };

    const updateMember = (
        memberId: string,
        field: keyof TeamMember,
        value: string
    ) => {
        const updatedMembers = teamMembers.map((member) =>
            member.id === memberId ? { ...member, [field]: value } : member
        );
        onTeamMembersChange(updatedMembers);
    };

    return (
        <div className="">
            <div className="flex items-center justify-between py-4 border-t border-b border-gray-200 mx-2">
                <h3 className="text-sm font-medium text-gray-700 text-nowrap">
                    Team Member
                </h3>
                <button
                    onClick={addTeamMember}
                    className="text-teal-500 text-sm font-medium hover:text-teal-600 cursor-pointer text-nowrap"
                >
                    + Add Member
                </button>
            </div>

            {/* Members List */}
            <div className="space-y-0 px-2">
                {teamMembers.map((member, index) => (
                    <div key={member.id} className="border-b border-gray-200">
                        {/* Member Header */}
                        <div
                            className="flex items-center justify-between py-3 bg-white cursor-pointer hover:bg-gray-50"
                            onClick={() => toggleMember(member.id)}
                        >
                            <span className="text-sm font-medium text-gray-900">
                                Member {index + 1}
                            </span>
                            <div className="flex items-center gap-2 text-gray-600">
                                <button
                                    onClick={(e) => {
                                        e.stopPropagation();
                                        removeTeamMember(member.id);
                                    }}
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
                            <div className="py-4 space-y-4 bg-white px-2">
                                {/* Image Upload */}
                                <div>
                                    <label className="block text-sm font-medium mb-2">
                                        Image
                                    </label>
                                    <input
                                        ref={(el) => {
                                            teamMemberRefs.current[member.id] = el;
                                        }}
                                        type="file"
                                        accept="image/*"
                                        onChange={(e) =>
                                            handleTeamMemberImageSelect(
                                                member.id,
                                                e
                                            )
                                        }
                                        className="hidden"
                                    />
                                    <div
                                        onClick={() =>
                                            teamMemberRefs.current[
                                                member.id
                                            ]?.click()
                                        }
                                        className="relative bg-slate-gray rounded-lg overflow-hidden flex items-center justify-center w-38 h-44 border-2 border-dashed border-extra-light-gray group cursor-pointer"
                                    >
                                        {member.image ? (
                                            <>
                                                {/* Blurred Background Image */}
                                                <AppImage
                                                    src={member.image}
                                                    alt={`Member ${index + 1} background`}
                                                    width={200}
                                                    height={208}
                                                    className="absolute inset-0 w-full h-full object-cover blur-xl scale-110 opacity-30"
                                                />
                                                {/* Main Image */}
                                                <AppImage
                                                    src={member.image}
                                                    alt={`Member ${index + 1}`}
                                                    width={200}
                                                    height={208}
                                                    className="relative w-full h-full object-contain"
                                                />
                                                {/* Hover Overlay */}
                                                <div className="absolute inset-0 bg-black/0 group-hover:bg-black/20 transition-all duration-300 z-10">
                                                    {/* Pencil Icon - Top Right */}
                                                    <div className="absolute top-2 right-2">
                                                        <div className="bg-white rounded-full p-1.5 shadow-md opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                                                            <Pencil className="w-4 h-4 text-gray-700" />
                                                        </div>
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
                            </div>
                        )}
                    </div>
                ))}
            </div>
        </div>
    );
}
