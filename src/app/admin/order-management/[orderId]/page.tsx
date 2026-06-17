"use client";

import React from "react";
import Image from "next/image";
import { useParams, useRouter } from "next/navigation";
import { LeftArrowIcon } from "@/components/icons";
import { useGetOrderByIdQuery } from "@/store/api/orderApi";
import { format } from "date-fns";

export default function OrderDetailPage() {
    const params = useParams();
    const router = useRouter();
    const orderId = params.orderId as string;

    const { data: orderData, isLoading, error } = useGetOrderByIdQuery(orderId);
    const order = orderData?.data?.order;

    if (isLoading) {
        return (
            <div className="min-h-screen bg-gray-50 flex justify-center items-center">
                <div className="text-lg text-gray-600">Loading...</div>
            </div>
        );
    }

    if (error || !order) {
        return (
            <div className="min-h-screen bg-gray-50 flex justify-center items-center">
                <div className="text-lg text-red-600">Order not found</div>
            </div>
        );
    }

    const formatDate = (dateString: string | null) => {
        if (!dateString) return "-";
        try {
            return format(new Date(dateString), "MMMM dd, yyyy 'at' hh:mm a");
        } catch {
            return "-";
        }
    };

    const formatPrice = (amount: number | null | undefined) => {
        if (amount === null || amount === undefined || isNaN(amount)) {
            return "0.00";
        }
        return amount.toFixed(2);
    };

    const customerName = order.customer
        ? `${order.customer.firstName || ""} ${order.customer.lastName || ""}`.trim() || "-"
        : "Guest User";

    const shippingAddressLines = order.shippingAddress
        ? [
            `${order.shippingAddress.firstName} ${order.shippingAddress.lastName}`,
            `${order.shippingAddress.streetName} ${order.shippingAddress.houseNumber}${order.shippingAddress.houseNumberAddition ? ` ${order.shippingAddress.houseNumberAddition}` : ""}`,
            order.shippingAddress.address,
            `${order.shippingAddress.city}, ${order.shippingAddress.postalCode}`,
            order.shippingAddress.country,
        ].filter(Boolean).join("\n")
        : "-";

    const statusColors: Record<string, string> = {
        Delivered: "bg-green-100 text-green-800",
        Processing: "bg-orange-100 text-orange-800",
        Shipped: "bg-blue-100 text-blue-800",
        Cancelled: "bg-red-100 text-red-800",
        Pending: "bg-yellow-100 text-yellow-800",
        Confirmed: "bg-teal-100 text-teal-800",
        Refunded: "bg-gray-100 text-gray-800",
    };

    return (
        <div className="min-h-screen bg-gray-50 flex justify-center">
            <div className="w-full max-w-5xl">
                {/* Back + Header */}
                <button
                    onClick={() => router.back()}
                    className="flex items-center gap-3 mb-1 text-gray-700 hover:text-gray-900 transition-colors cursor-pointer"
                >
                    <div className="mt-1"><LeftArrowIcon /></div>
                    <div className="text-xl font-semibold">Order {order.orderNumber}</div>
                </button>
                <div className="text-sm text-text-gray mb-4 ml-5.5">{formatDate(order.orderDate)}</div>

                <div className="grid grid-cols-1 lg:grid-cols-5 gap-6">
                    {/* Left: Items + pricing */}
                    <div className="lg:col-span-3 space-y-6">
                        <div className="bg-white rounded-lg border border-extra-light-gray">
                            <div className="flex justify-between w-full items-center">
                                <h2 className="text-lg font-semibold px-4 pt-2 ">Items Ordered</h2>
                                <div className="mt-2 px-4 pt-3">
                                    <span className={`inline-flex items-center px-3 py-1 rounded-md text-xs font-medium ${statusColors[order.status] || "bg-gray-100 text-gray-800"}`}>
                                        {order.status}
                                    </span>
                                </div>
                            </div>
                            <div className="p-4">
                                <div className="bg-white rounded-lg border border-extra-light-gray overflow-hidden">
                                    <div className="divide-y divide-extra-light-gray">
                                        {order.items.map((item, idx) => {
                                            return (
                                            <div key={idx} className="flex items-center justify-between px-4 py-4">
                                                <div className="flex items-center gap-3">
                                                    <div className="relative w-10 h-10 rounded-md overflow-hidden bg-gray-200">
                                                        <Image
                                                            src={item.product?.productImage || "/placeholder-product.png"}
                                                            alt={item.name}
                                                            fill
                                                            className="object-cover"
                                                        />
                                                    </div>

                                                    <div>
                                                        <div className="text-sm font-medium text-gray-900">
                                                            {item.product?.title || item.name}
                                                        </div>
                                                        <div className="text-xs text-text-gray">
                                                            {item.capsuleCount ? `${item.capsuleCount} capsules` : `${item.durationDays} days`}
                                                        </div>
                                                    </div>
                                                </div>

                                                <div className="text-sm">
                                                    {order.pricing.overall.currency} {formatPrice(item.totalAmount)}
                                                </div>
                                            </div>
                                        )})}
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div className="bg-white rounded-lg border border-extra-light-gray">
                            <div className="flex flex-col p-4">
                                <h2 className="text-lg font-semibold px-4">Pricing Summary</h2>
                                <div className="bg-white w-full rounded-lg border border-extra-light-gray overflow-hidden mt-4">
                                    <div className="text-sm">
                                        <div className="flex justify-between px-4 py-1.5">
                                            <span>Subtotal</span>
                                            <span>{order.pricing.overall.currency} {formatPrice(order.pricing.overall.subTotal)}</span>
                                        </div>

                                        {order.pricing.overall.discountedPrice < order.pricing.overall.subTotal && (
                                            <div className="flex justify-between px-4 py-1.5">
                                                <span>Discounted Price</span>
                                                <span>
                                                    {order.pricing.overall.currency} {formatPrice(order.pricing.overall.discountedPrice)}
                                                </span>
                                            </div>
                                        )}

                                        {(order.pricing.overall.couponDiscountAmount || 0) > 0 && (
                                            <div className="flex justify-between px-4 py-1.5">
                                                <span>Coupon Discount</span>
                                                <span className="text-red-600">
                                                    - {order.pricing.overall.currency} {formatPrice(order.pricing.overall.couponDiscountAmount)}
                                                </span>
                                            </div>
                                        )}

                                        {(order.pricing.overall.membershipDiscountAmount || 0) > 0 && (
                                            <div className="flex justify-between px-4 py-1.5">
                                                <span>Membership Discount</span>
                                                <span className="text-red-600">
                                                    - {order.pricing.overall.currency} {formatPrice(order.pricing.overall.membershipDiscountAmount)}
                                                </span>
                                            </div>
                                        )}

                                        {(order.pricing.overall.subscriptionPlanDiscountAmount || 0) > 0 && (
                                            <div className="flex justify-between px-4 py-1.5">
                                                <span>Subscription Discount</span>
                                                <span className="text-red-600">
                                                    - {order.pricing.overall.currency} {formatPrice(order.pricing.overall.subscriptionPlanDiscountAmount)}
                                                </span>
                                            </div>
                                        )}

                                        <div className="flex justify-between px-4 py-1.5">
                                            <span>Tax</span>
                                            <span>{order.pricing.overall.currency} {formatPrice(order.pricing.overall.taxAmount)}</span>
                                        </div>

                                        <div className="flex justify-between border-t border-extra-light-gray px-4 py-3 font-semibold">
                                            <span>Total</span>
                                            <span>{order.pricing.overall.currency} {formatPrice(order.pricing.overall.grandTotal)}</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>

                    {/* Right: Customer + Order Summary */}
                    <div className="lg:col-span-2 space-y-6">
                        <div className="bg-white rounded-lg border border-extra-light-gray">
                            <h2 className="text-lg font-semibold px-4 py-3 border-b border-extra-light-gray">Customer</h2>
                            <div className="p-4 space-y-4 text-sm">
                                <div>
                                    <div className="text-blue-600 font-medium cursor-pointer">{customerName}</div>
                                    <div className="text-gray-600">{order.totalOrders} {order.totalOrders === 1 ? "order" : "orders"}</div>
                                </div>
                                <div>
                                    <p className="text-text-gray">Contact information</p>
                                    {order.customer?.email ? (
                                        <a href={`mailto:${order.customer.email}`} className="text-teal-600">{order.customer.email}</a>
                                    ) : <p className="text-gray-900">-</p>}
                                    <p className="text-text-gray">{order.customer?.phone || "No phone number"}</p>
                                </div>
                                <div>
                                    <p className="text-text-gray">Shipping address</p>
                                    <p className="text-gray-900 whitespace-pre-line">{shippingAddressLines}</p>
                                </div>
                                <div>
                                    <p className="text-text-gray">Billing address</p>
                                    <p className="text-gray-900">Same as shipping address</p>
                                </div>
                            </div>
                        </div>

                        <div className="bg-white rounded-lg border border-extra-light-gray">
                            <h2 className="text-lg font-semibold px-4 py-3 border-b border-extra-light-gray">Order Summary</h2>
                            <div className="p-4 space-y-3 text-sm">
                                <div>
                                    <p className="text-text-gray">Order Type</p>
                                    <span className="inline-flex items-center px-3 py-1 mt-1 rounded-md text-xs font-medium bg-blue-100 text-blue-800">
                                        {order.planType}
                                    </span>
                                </div>
                                <div>
                                    <p className="text-text-gray">Payment method</p>
                                    <span className="inline-flex items-center px-3 py-1 mt-1 rounded-md text-xs font-medium bg-purple-100 text-purple-800">
                                        {order.paymentMethod || "-"}
                                    </span>
                                </div>
                                <div>
                                    <p className="text-text-gray">Payment Status</p>
                                    <p className="text-gray-900">{order.paymentStatus || "-"}</p>
                                </div>
                                <div>
                                    <p className="text-text-gray">Tracking Number</p>
                                    <p className="text-gray-900">{order.trackingNumber || "-"}</p>
                                </div>
                                <div>
                                    <p className="text-text-gray">Shipped Date</p>
                                    <p className="text-gray-900">{order.shippedAt ? formatDate(order.shippedAt) : "-"}</p>
                                </div>
                                <div>
                                    <p className="text-text-gray">Delivery Date</p>
                                    <p className="text-gray-900">{order.deliveredAt ? formatDate(order.deliveredAt) : "-"}</p>
                                </div>
                                {order.couponCode && (
                                    <div>
                                        <p className="text-text-gray">Coupon Code</p>
                                        <p className="text-gray-900">{order.couponCode}</p>
                                    </div>
                                )}
                            </div>
                        </div>

                        {/* Subscription details card */}
                        {order.metadata?.planDetails && !order.metadata.planDetails.isOneTime && (
                            <div className="bg-white rounded-lg border border-extra-light-gray">
                                <h2 className="text-lg font-semibold border-b border-extra-light-gray px-4 py-3">Subscription details</h2>
                                <div className="space-y-4 px-4 py-3">
                                    <div>
                                        <p className="text-sm text-text-gray uppercase mb-1">Plan Type</p>
                                        <p className="text-sm font-medium">{order.metadata.planDetails.planType}</p>
                                    </div>
                                    {order.metadata.planDetails.sachets && (
                                        <>
                                            <div>
                                                <p className="text-sm text-text-gray uppercase mb-1">Plan Duration</p>
                                                <p className="text-sm font-medium">{order.metadata.planDetails.sachets.planDurationDays} days</p>
                                            </div>
                                            <div>
                                                <p className="text-sm text-text-gray uppercase mb-1">Billing Cycle</p>
                                                <p className="text-sm font-medium">Every {order.metadata.planDetails.sachets.cycleDays} days</p>
                                            </div>
                                        </>
                                    )}
                                    {order.metadata.planDetails.standUpPouch && (
                                        <div>
                                            <p className="text-sm text-text-gray uppercase mb-1">Item Quantities</p>
                                            <div className="space-y-1">
                                                {order.metadata.planDetails.standUpPouch.itemQuantities.map((item, idx) => (
                                                    <div key={idx} className="text-sm">
                                                        Product ID: {item.productId} - {item.quantity} units ({item.capsuleCount} capsules, {item.planDays} days)
                                                    </div>
                                                ))}
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </div>
                        )}
                        
                        {/* Order metadata card */}
                        {(order.metadata?.isRenewalOrder || order.metadata?.isSubscriptionChange) && (
                            <div className="bg-white rounded-lg border border-extra-light-gray">
                                <h2 className="text-lg font-semibold border-b border-extra-light-gray px-4 py-3">Order Information</h2>
                                <div className="space-y-4 px-4 py-3">
                                    {order.metadata?.isRenewalOrder && (
                                        <div>
                                            <p className="text-sm text-text-gray uppercase mb-1">Order Type</p>
                                            <p className="text-sm font-medium">Renewal Order</p>
                                        </div>
                                    )}
                                    {order.metadata?.isSubscriptionChange && (
                                        <div>
                                            <p className="text-sm text-text-gray uppercase mb-1">Subscription Change</p>
                                            <p className="text-sm font-medium">Yes</p>
                                            {order.metadata.effectiveDate && (
                                                <p className="text-xs text-gray-600 mt-1">
                                                    Effective: {formatDate(order.metadata.effectiveDate)}
                                                </p>
                                            )}
                                        </div>
                                    )}
                                    {order.metadata?.originalOrderId && (
                                        <div>
                                            <p className="text-sm text-text-gray uppercase mb-1">Original Order</p>
                                            <p className="text-sm font-medium">{order.metadata.originalOrderId}</p>
                                        </div>
                                    )}
                                </div>
                            </div>
                        )}


                    </div>
                </div>
            </div>
        </div>
    );
}
