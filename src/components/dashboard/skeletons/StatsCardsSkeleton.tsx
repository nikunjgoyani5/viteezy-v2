export function StatsCardsSkeleton() {
  const totalItems = 5;
  return (
    <section>
      <div className="grid sm:grid-cols-2  xl:grid-cols-5 rounded-xl border overflow-hidden divide-y sm:divide-y-0 bg-white">
        {Array.from({ length: totalItems }).map((_, i) => {
          const isLeftInTwoCol = i % 2 === 0;
          const isLast = i === totalItems - 1;
          const isSecondLast = i === totalItems - 2;
          const isLastRowInTwoCol =
            totalItems % 2 === 0 ? isLast || isSecondLast : isLast;
          return (
            <div
              key={i}
              className={`p-5 min-h-37
        ${isLeftInTwoCol ? "border-r xl:border-r-2 sm:border-border" : ""}
        xl:border-r-2 xl:last:border-r-0
        ${!isLastRowInTwoCol ? "sm:border-b sm:border-border xl:border-0" : ""}
        `}
            >
              <div className="h-4 w-32 bg-gray-200 rounded animate-pulse" />
              <div className="my-4 h-9 w-24 bg-gray-200 rounded animate-pulse" />
              <div className="flex items-center gap-2">
                <div className="h-4 w-16 bg-gray-200 rounded animate-pulse" />
                <div className="h-4 w-24 bg-gray-200 rounded animate-pulse" />
              </div>
            </div>
          );
        })}
      </div>
    </section>
  );
}
