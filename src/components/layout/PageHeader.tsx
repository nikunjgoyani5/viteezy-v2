import { cn } from "@/lib/utils";

type PageHeaderProps = {
  title: string;
  description?: string;
  actions?: React.ReactNode;
  className?: string;
};

export function PageHeader({
  title,
  description,
  actions,
  className,
}: PageHeaderProps) {
  return (
    <div
      className={cn("mb-5 flex items-center justify-between gap-4", className)}
    >
      <div className="min-w-0">
        <h1 className="text-[24px] 3xl:text-[28px] font-semibold leading-none">{title}</h1>
        {description ? (
          <p className="mt-2 text-sm text-text-gray">{description}</p>
        ) : null}
      </div>

      {actions ? (
        <div className="shrink-0 flex items-center gap-2">{actions}</div>
      ) : null}
    </div>
  );
}
