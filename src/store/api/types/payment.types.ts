// Payment API Types

export interface CreatePaymentRequest {
    orderId: string;
    paymentMethod: string;
}

export interface Payment {
    _id: string;
    orderId: string;
    paymentMethod: string;
    amount: number;
    currency: string;
    status: string;
    paymentUrl?: string;
    transactionId?: string;
    createdAt: string;
    updatedAt: string;
}

export interface CreatePaymentResponse {
    success: boolean;
    message: string;
    data: {
        payment: Payment;
        paymentUrl?: string;
    };
}
