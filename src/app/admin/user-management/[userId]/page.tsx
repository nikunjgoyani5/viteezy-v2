"use client";

import React from "react";
import { useParams, useRouter } from "next/navigation";
import { MdArrowBack, MdKeyboardArrowDown, MdKeyboardArrowUp } from "react-icons/md";
import Image from "next/image";
import { LeftArrowIcon } from "@/components/icons";
import { useGetUserByIdQuery } from "@/store/api/userApi";

interface Order {
    id: string;
    type: "stripe" | "mollie";
    date: string;
    amount: number;
    products: {
        name: string;
        image: string;
        duration: string;
        price: number;
    }[];
}

interface FamilyMember {
    name: string;
    email: string;
    phone: string;
    avatar: string;
    registeredAt: string;
}

// Helpers
const formatDate = (iso?: string) => {
    if (!iso) return "-";
    const d = new Date(iso);
    if (isNaN(d.getTime())) return "-";
    return d.toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" });
};

const formatDateTime = (iso?: string) => {
    if (!iso) return "-";
    const d = new Date(iso);
    if (isNaN(d.getTime())) return "-";
    return d.toLocaleString("en-US", { year: "numeric", month: "long", day: "numeric", hour: "numeric", minute: "2-digit" });
};

const UserDetailPage = () => {
    const params = useParams();
    const router = useRouter();
    const userId = params.userId as string;
    const [expandedOrders, setExpandedOrders] = React.useState<string[]>([]);

    const { data, isLoading, isError } = useGetUserByIdQuery(userId);

    const apiUser = data?.data?.user;
    const latestSubscription = React.useMemo(() => {
        if (!apiUser?.subscriptionDetails || apiUser.subscriptionDetails.length === 0) return undefined;
        return [...apiUser.subscriptionDetails].sort((a, b) => new Date(b.purchaseDate).getTime() - new Date(a.purchaseDate).getTime())[0];
    }, [apiUser]);

    const user = React.useMemo(() => {
        if (!apiUser) return null;
        const fullName = `${apiUser.firstName ?? ""} ${apiUser.lastName ?? ""}`.trim();
        const membershipType = apiUser.isPremiumMember ? "Premium Member" : "Member";
        const status = apiUser.isActive ? "Active" : "Inactive";

        const personalAddress = apiUser.personalDetails?.address;
        const fullAddress = personalAddress?.address
            || [personalAddress?.streetName, personalAddress?.houseNumber, personalAddress?.houseNumberAddition]
                .filter(Boolean).join(" ");

        const linkedFamily = (apiUser.linkedFamilyList ?? []).map((m) => ({
            name: `${m.firstName ?? ""} ${m.lastName ?? ""}`.trim() || "Unknown",
            email: m.email || "-",
            phone: m.phone ? (m.countryCode ? `${m.countryCode} ${m.phone}` : m.phone) : "-",
            avatar: m.profileImage ?? "/images/avatar-placeholder.jpg",
            registeredAt: formatDateTime(m.registeredAt),
        }));

        const orders = (apiUser.recentOrders ?? []).map((o) => ({
            id: o.orderNumber,
            type: (o.paymentMethod || "Stripe").toLowerCase() as "stripe" | "mollie",
            date: formatDateTime(o.orderCreatedDate),
            amount: o.orderTotalAmount,
            products: (o.items || []).map((p) => ({
                name: p.productName,
                image: p.productImage,
                duration: `${p.planDays}Day`,
                price: p.productPrice?.totalAmount ?? 0,
            })),
        }));

        return {
            name: fullName || "-",
            email: apiUser.personalDetails?.email ?? "-",
            phone: apiUser.personalDetails?.phone ?? "-",
            memberId: apiUser.membershipId ?? "-",
            registrationDate: formatDate(apiUser.registrationDate),
            status,
            membershipType,
            avatar: apiUser.profileImage,
            stats: {
                totalOrders: apiUser.totalOrderCount ?? 0,
                totalSpent: apiUser.totalSpent?.amount ?? 0,
            },
            subscription: latestSubscription
                ? {
                    purchaseDate: formatDate(latestSubscription.purchaseDate),
                    nextBillingDate: formatDate(latestSubscription.nextBillingDate),
                    daysPlans: `${latestSubscription.dayPlans} Day`,
                }
                : {
                    purchaseDate: "-",
                    nextBillingDate: "-",
                    daysPlans: "-",
                },
            membership: {
                planStartDate: formatDate(apiUser.membership?.planStartDate),
                planExpiry: formatDate(apiUser.membership?.planEndDate),
                status: apiUser.membership?.membershipStatus ?? "-",
            },
            personalDetails: {
                fullAddress: fullAddress ?? "-",
                email: apiUser.personalDetails?.email ?? "-",
                mobileNumber: apiUser.personalDetails?.phone ?? "-",
                language: apiUser.personalDetails?.language ?? "-",
            },
            linkedFamily,
            orders,
        };
    }, [apiUser, latestSubscription]);

    const toggleOrder = (orderId: string) => {
        setExpandedOrders((prev) =>
            prev.includes(orderId)
                ? prev.filter((id) => id !== orderId)
                : [...prev, orderId]
        );
    };

    if (isLoading) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                <div className="text-gray-500">Loading user details...</div>
            </div>
        );
    }

    if (isError || !user) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                <div className="text-red-500">Failed to load user details.</div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gray-50  flex justify-center">
            <div className="w-full max-w-4xl">
                {/* Back Button */}
                <button
                    onClick={() => router.back()}
                    className="flex items-center gap-3 mb-6 text-gray-700 hover:text-gray-900 transition-colors cursor-pointer"
                >
                    <div className="mt-1"><LeftArrowIcon /></div>
                    <div className="text-xl font-semibold">{user.name}</div>
                </button>

                {/* User Profile Card */}
                <div className="bg-white rounded-lg border border-extra-light-gray p-6 mb-6">
                    <div className="flex items-center gap-6">
                        <div className="relative w-18 h-18 rounded-full overflow-hidden bg-gray-200 flex-shrink-0">
                            {user.avatar ? (
                                <Image
                                    src={user.avatar}
                                    alt={user.name}
                                    fill
                                    className="object-cover"
                                    onError={(e) => {
                                        // Fallback to initials if image fails
                                        e.currentTarget.style.display = "none";
                                    }}
                                />
                            ) : (
                                <div className="absolute inset-0 flex items-center justify-center text-3xl font-medium text-gray-600">
                                    {(user.name || "User").slice(0, 2).toUpperCase()}
                                </div>
                            )}
                        </div>
                        <div className="flex-1">
                            <div className="flex items-center gap-3 mb-1">
                                <h1 className="text-2xl font-semibold ">{user.name}</h1>
                                <span className="pl-2 pr-3 py-1 bg-soft-wheat text-burnt-copper rounded-md text-xs font-medium">
                                    {user.membershipType}
                                </span>
                                <span className="pl-2 pr-3 py-1 bg-parrot-green text-dark-green rounded-md text-xs font-medium">
                                    {user.status}
                                </span>
                            </div>
                            <div className="flex items-center gap-2 text-sm  text-text-gray">
                                <span>Registration Date {user.registrationDate}</span>
                                <span className="text-xl">•</span>
                                <span>{user.memberId}</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
                    {/* Left Column - Stats, Subscription, Membership */}
                    <div className="lg:col-span-2 space-y-6">
                        {/* Stats Cards */}
                        <div className="grid grid-cols-2 gap-4">
                            <div className="bg-white rounded-lg border border-extra-light-gray p-4">
                                <p className="text-sm mb-2">Total Orders</p>
                                <p className="text-2xl font-semibold ">{user.stats.totalOrders ? user.stats.totalOrders : 0}</p>
                            </div>
                            <div className="bg-white rounded-lg border border-extra-light-gray p-4">
                                <p className="text-sm  mb-2">Total Spent</p>
                                <p className="text-2xl font-semibold ">${(user.stats.totalSpent ? user.stats.totalSpent : 0).toFixed(1)}</p>
                            </div>
                        </div>

                        {/* Subscription Card */}
                        <div className="bg-white rounded-lg border border-extra-light-gray ">
                            <h2 className="text-lg font-semibold   border-b border-extra-light-gray px-4 py-3">Subscription</h2>
                            <div className="space-y-4 p-4">
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Purchase Date</p>
                                    <p className="text-sm font-medium ">{user.subscription.purchaseDate}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Next Billing Date</p>
                                    <p className="text-sm font-medium ">{user.subscription.nextBillingDate}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Days Plans</p>
                                    <p className="text-sm font-medium ">{user.subscription.daysPlans}</p>
                                </div>
                            </div>
                        </div>

                        {/* Membership Card */}
                        <div className="bg-white rounded-lg border border-extra-light-gray">
                            <h2 className="text-lg font-semibold   border-b border-extra-light-gray px-4 py-3">Membership</h2>
                            <div className="space-y-4 px-4 py-3">
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Plan Start Date</p>
                                    <p className="text-sm font-medium">{user.membership.planStartDate}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Plan Expiry</p>
                                    <p className="text-sm font-medium">{user.membership.planExpiry}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Membership</p>
                                    <p className="text-sm font-medium text-golden-mango">{user.membership.status}</p>
                                </div>
                            </div>
                        </div>

                        {/* Personal Details Card */}
                        <div className="bg-white rounded-lg border border-extra-light-gray">
                            <h2 className="text-lg font-semibold   border-b border-extra-light-gray px-4 py-3">Personal Details</h2>
                            <div className="space-y-4 px-4 py-3">
                                <div>
                                    <p className="text-sm text-text-gray mb-1">Full Address</p>
                                    <p className="text-sm font-medium text-gray-900">{user.personalDetails.fullAddress}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray mb-1">Email</p>
                                    <p className="text-sm font-medium text-gray-900">{user.personalDetails.email}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray mb-1">mobile number</p>
                                    <p className="text-sm font-medium text-gray-900">{user.personalDetails.mobileNumber}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray mb-1">Language</p>
                                    <p className="text-sm font-medium text-gray-900">{user.personalDetails.language}</p>
                                </div>
                            </div>
                        </div>

                        {/* Linked Family Card */}
                        {user.linkedFamily.length > 0 && (
                            <div className="bg-white rounded-lg border border-extra-light-gray">
                                <h2 className="text-lg font-semibold   border-b border-extra-light-gray px-4 py-3">Linked Family</h2>
                                <div className="space-y-4 px-4 py-3">
                                    {user.linkedFamily.map((member, index) => (
                                        <div key={index} className="flex items-center gap-4">
                                            <div className="relative w-14 h-14 rounded-full overflow-hidden bg-gray-200 flex-shrink-0">
                                                <Image
                                                    src={member.avatar}
                                                    alt={member.name}
                                                    fill
                                                    className="object-cover"
                                                    onError={(e) => {
                                                        e.currentTarget.style.display = "none";
                                                    }}
                                                />
                                                <div className="absolute inset-0 flex items-center justify-center text-lg font-semibold text-gray-600">
                                                    {(member.name || "Unknown").slice(0, 2).toUpperCase()}
                                                </div>
                                            </div>
                                            <div className="flex-1">
                                                <p className="text-sm font-semibold ">{member.name}</p>
                                                <p className="text-sm text-text-gray">{member.email}</p>
                                                <p className="text-sm text-text-gray">{member.phone}</p>
                                                <p className="text-xs text-text-gray mt-1">Registered: {member.registeredAt}</p>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>
                        )}
                    </div>

                    {/* Right Column - Recent Orders */}
                    <div className="lg:col-span-3">
                        <div className="bg-white rounded-lg border border-extra-light-gray ">
                            <h2 className="text-lg font-semibold text-gray-900 px-4 py-3">Recent Order</h2>
                            <div>
                                {user.orders.length === 0 ? (
                                    <div className="border-t border-gray-200 px-4 py-8 text-center">
                                        <p className="text-gray-500 text-sm">No orders available</p>
                                    </div>
                                ) : (
                                    user.orders.map((order, index) => (
                                        <div key={`${order.id}-${index}`} className="border-t border-gray-200 px-4">
                                            {/* Order Header */}
                                            <div
                                                className="cursor-pointer  transition-colors py-3"
                                                onClick={() => toggleOrder(`${order.id}-${index}`)}
                                            >
                                                <div className="flex items-center justify-center">
                                                    <div className="flex-1 flex justify-center flex-col ">
                                                        <div className="flex items-center gap-3 ">
                                                            <span className="font-semibold text-gray-900">#{order.id}</span>
                                                            <span
                                                                className={`px-2 flex items-center justify-end  rounded-full text-[10px] font-medium ${order.type === "stripe"
                                                                    ? "bg-ultra-blue text-white"
                                                                    : "bg-black text-white"
                                                                    }`}
                                                            >
                                                                {order.type}
                                                            </span>
                                                        </div>
                                                        <span className="text-sm text-text-gray font-medium">{order.date}</span>
                                                    </div>
                                                    <div className="flex items-center gap-2">
                                                        <span className="text-base font-semibold text-gray-900">
                                                            ${order?.amount?.toFixed(2)}
                                                        </span>
                                                        {expandedOrders.includes(`${order.id}-${index}`) ? (
                                                            <MdKeyboardArrowUp size={24} className="text-gray-600" />
                                                        ) : (
                                                            <MdKeyboardArrowDown size={24} className="text-gray-600" />
                                                        )}
                                                    </div>
                                                </div>
                                            </div>

                                            {/* Order Details - Expandable */}
                                            <div
                                                className={`overflow-hidden transition-all duration-400 ease-in-out ${expandedOrders.includes(`${order.id}-${index}`) && order.products.length > 0
                                                    ? 'max-h-[1000px] opacity-100'
                                                    : 'max-h-0 opacity-0'
                                                    }`}
                                            >
                                                <div className="flex flex-col gap-4 pb-4">
                                                    {order.products.map((product, productIndex) => (
                                                        <div
                                                            key={productIndex}
                                                            className="flex items-center justify-between"
                                                        >
                                                            <div className="flex items-center gap-2">
                                                                <div className="w-12 h-12 bg-gray-200 rounded overflow-hidden flex-shrink-0">
                                                                    <Image
                                                                        src={product.image}
                                                                        alt={product.name}
                                                                        width={48}
                                                                        height={48}
                                                                        className="object-cover"
                                                                        onError={(e) => {
                                                                            e.currentTarget.style.display = "none";
                                                                        }}
                                                                    />
                                                                </div>
                                                                <span className="text-sm font-medium ">
                                                                    {product.name}
                                                                </span>
                                                            </div>
                                                            <div className="flex items-center gap-6 text-sm">
                                                                <span className="font-semibold">{product.duration}</span>
                                                                <span className="font-semibold text-text-gray">
                                                                    ${product.price.toFixed(2)}
                                                                </span>
                                                            </div>
                                                        </div>
                                                    ))}
                                                </div>
                                            </div>
                                        </div>
                                    ))
                                )}
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div >
    );
};

export default UserDetailPage;
