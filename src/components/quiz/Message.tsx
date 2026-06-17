import { ChatMessage } from "../types/quiz";
import BotAvatar from "./BotAvatar";
import ProductResponse from "./ProductResponse";

interface MessageProps {
  message: ChatMessage;
  onProductSelect?: (productId: string) => void;
}

export default function Message({ message, onProductSelect }: MessageProps) {
  const { content, isUser, type, products } = message;

  if (type === "products" && products && products.length > 0) {
    return (
      <div
        id={`message-${message.id}`}
        className="mb-6 animate-in fade-in slide-in-from-bottom-4 duration-300"
      >
        <ProductResponse
          // eslint-disable-next-line @typescript-eslint/no-explicit-any
          products={products as any}
          onProductSelect={onProductSelect}
        />
      </div>
    );
  }

  return (
    <div
      id={`message-${message.id}`}
      className={`flex ${
        isUser ? "justify-end" : "justify-start"
      } mb-6 animate-in fade-in slide-in-from-bottom-4 duration-300`}
    >
      <div className={`max-w-[80%] ${isUser ? "ml-auto" : "mr-auto"}`}>
        <div
          className={`flex items-start gap-3 ${
            isUser ? "flex-row-reverse" : ""
          }`}
        >
          {!isUser && <BotAvatar />}

          <div
            className={`
              px-4 py-3 rounded-full
              ${
                isUser
                  ? "bg-white rounded-tr-none  border border-neutral-sand-100"
                  : ""
              }
            `}
          >
            <p className="whitespace-pre-wrap leading-relaxed text-lg">
              {content}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
