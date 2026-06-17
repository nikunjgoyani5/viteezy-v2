"use client";

import React, { useEffect, useState } from "react";
import { useParams, useRouter } from "next/navigation";
import { LeftArrowIcon } from "@/components/icons";
import { getAuthToken } from "@/lib/token";

interface SubscriptionData {
    subscription: {
        id: string;
        subscriptionNumber: string;
        status: string;
        planType: string;
        cycleDays: number;
        user: {
            id: string;
            firstName: string;
            lastName: string;
            email: string;
            fullName: string;
        };
        order?: {
            id: string;
            orderNumber: string;
            paymentStatus: string;
            paymentMethod: string;
            grandTotal: number;
            currency: string;
            pausedAt: string | null;
            pausedUntil: string | null;
        };
        payments: Array<{
            id: string;
            paymentMethod: string;
            status: string;
            processedAt: string;
            amount: {
                amount: number;
                currency: string;
                taxRate: number;
            };
        }>;
        renewalHistory: Array<{
            id: string;
            renewalNumber: number;
            renewalDate: string;
            amount: {
                amount: number;
                currency: string;
                taxRate: number;
            };
            status: string;
            failureReason?: string;
        }>;
    };
}

export default function SubscriptionDetailPage() {
    const params = useParams();
    const router = useRouter();
    const subscriptionId = params.subscriptionId as string;

    const [subscription, setSubscription] = useState<SubscriptionData["subscription"] | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const fetchSubscription = async () => {
            try {
                setLoading(true);
                const token = getAuthToken();

                const response = await fetch(
                    `${process.env.NEXT_PUBLIC_API_BASE_URL}/admin/subscriptions/${subscriptionId}`,
                    {
                        headers: {
                            "Authorization": `Bearer ${token}`,
                            "Content-Type": "application/json",
                        },
                    }
                );

                if (!response.ok) {
                    throw new Error("Failed to fetch subscription details");
                }

                const result = await response.json();
                setSubscription(result.data.subscription);
            } catch (err) {
                setError(err instanceof Error ? err.message : "An error occurred");
            } finally {
                setLoading(false);
            }
        };

        if (subscriptionId) {
            fetchSubscription();
        }
    }, [subscriptionId]);

    if (loading) {
        return (
            <div className="min-h-screen bg-gray-50 flex justify-center items-center">
                <div className="text-gray-600">Loading subscription details...</div>
            </div>
        );
    }

    if (error || !subscription) {
        return (
            <div className="min-h-screen bg-gray-50 flex justify-center items-center">
                <div className="text-red-600">{error || "Subscription not found"}</div>
            </div>
        );
    }

    return (
        <div className="min-h-screen bg-gray-50 flex justify-center">
            <div className="w-full max-w-5xl">
                {/* Back + Header */}
                <button
                    onClick={() => router.back()}
                    className="flex items-center gap-3 mb-1 text-gray-700 hover:text-gray-900 transition-colors cursor-pointer"
                >
                    <div className="mt-1">
                        <LeftArrowIcon />
                    </div>
                    <div className="text-xl font-semibold">Subscription Details</div>
                </button>
                <div className="text-sm text-text-gray mb-4 ml-5.5">{subscription.subscriptionNumber}</div>

                <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
                    {/* Left: Renewal History + Transaction Logs */}
                    <div className="lg:col-span-3 space-y-6">
                        {/* Renewal History */}
                        <div className="bg-white rounded-lg border border-extra-light-gray">
                            <h2 className="text-lg font-semibold px-4 py-3 border-b border-extra-light-gray">
                                Renewal History
                            </h2>
                            <div className="p-4">
                                <div className="bg-white rounded-lg border border-extra-light-gray overflow-hidden">
                                    <div className="divide-y divide-extra-light-gray">
                                        {subscription.renewalHistory && subscription.renewalHistory.length > 0 ? (
                                            subscription.renewalHistory.map((renewal) => (
                                                <div key={renewal.id} className="flex items-center justify-between px-4 py-4">
                                                    <div>
                                                        <div className="text-sm font-medium text-gray-900">
                                                            {renewal.renewalDate ? new Date(renewal.renewalDate).toLocaleDateString('en-US', {
                                                                month: 'short',
                                                                day: 'numeric',
                                                                year: 'numeric'
                                                            }) : '-'}
                                                        </div>
                                                        {renewal.failureReason && (
                                                            <div className="text-xs text-red-600 mt-1">
                                                                {renewal.failureReason}
                                                            </div>
                                                        )}
                                                    </div>
                                                    <div className="flex items-center gap-3">
                                                        <div className="text-sm font-semibold">
                                                            {renewal.amount ? `${renewal.amount.currency} ${renewal.amount.amount.toFixed(2)}` : '-'}
                                                        </div>
                                                        <span className={`inline-flex items-center px-3 py-1 rounded-md text-xs font-medium ${renewal.status === "Completed"
                                                            ? "bg-parrot-green text-dark-green"
                                                            : "bg-soft-red text-hard-red"
                                                            }`}>
                                                            {renewal.status || '-'}
                                                        </span>
                                                    </div>
                                                </div>
                                            ))
                                        ) : (
                                            <div className="px-4 py-8 text-center text-sm text-gray-500">
                                                No renewal history available
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Transaction Logs (Payments) */}
                        <div className="bg-white rounded-lg border border-extra-light-gray">
                            <h2 className="text-lg font-semibold px-4 py-3 border-b border-extra-light-gray">
                                Transaction Logs
                            </h2>
                            <div className="p-4">
                                <div className="bg-white rounded-lg border border-extra-light-gray overflow-hidden">
                                    <div className="divide-y divide-extra-light-gray">
                                        {subscription.payments && subscription.payments.length > 0 ? (
                                            subscription.payments.map((payment) => (
                                                <div key={payment.id} className="flex items-center justify-between px-4 py-4">
                                                    <div>
                                                        <div className="text-sm font-medium text-gray-900">
                                                            {payment.processedAt ? new Date(payment.processedAt).toLocaleDateString('en-US', {
                                                                month: 'short',
                                                                day: 'numeric',
                                                                year: 'numeric'
                                                            }) : '-'} - {payment.paymentMethod || '-'}
                                                        </div>
                                                    </div>
                                                    <div>
                                                        {payment.status === "Completed" ? (
                                                            <span className="inline-flex items-center px-3 py-1 rounded-md text-xs font-medium bg-parrot-green text-dark-green">
                                                                Success
                                                            </span>
                                                        ) : (
                                                            <span className="inline-flex items-center px-3 py-1 rounded-md text-xs font-medium bg-soft-red text-hard-red">
                                                                Failed
                                                            </span>
                                                        )}
                                                    </div>
                                                </div>
                                            ))
                                        ) : (
                                            <div className="px-4 py-8 text-center text-sm text-gray-500">
                                                No transaction logs available
                                            </div>
                                        )}
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Right: Plan Details */}
                    <div className="lg:col-span-2 space-y-6">
                        <div className="bg-white rounded-lg border border-extra-light-gray">
                            <div className="flex items-center justify-between px-4 py-3 border-b border-extra-light-gray">
                                <h2 className="text-lg font-semibold">Plan Details</h2>
                                <span className={`inline-flex items-center px-3 py-1 rounded-md text-xs font-medium ${subscription.status === "Active"
                                    ? "bg-parrot-green text-dark-green"
                                    : "bg-soft-red text-hard-red"
                                    }`}>
                                    {subscription.status}
                                </span>
                            </div>
                            <div className="p-4 space-y-4 text-sm">
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Plan Type</p>
                                    <p className="text-sm font-medium">{subscription.planType || '-'}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Cycle Duration</p>
                                    <p className="text-sm font-medium">{subscription.cycleDays ? `${subscription.cycleDays} Days` : '-'}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Price</p>
                                    <p className="text-sm font-medium">{subscription.order?.grandTotal ? `${subscription.order.currency} ${subscription.order.grandTotal.toFixed(2)}` : '-'}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Customer Name</p>
                                    <p className="text-sm font-medium">{subscription.user?.fullName || '-'}</p>
                                </div>
                                <div>
                                    <p className="text-sm text-text-gray uppercase mb-1">Customer Email</p>
                                    <p className="text-sm font-medium">{subscription.user?.email || '-'}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}
