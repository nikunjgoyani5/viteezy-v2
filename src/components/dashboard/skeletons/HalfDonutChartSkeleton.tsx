const HalfDonutChartSkeleton = () => {
  return (
    <div className="w-full bg-white rounded-lg border p-5">
      <div className="h-5 w-48 bg-gray-200 rounded animate-pulse" />
      <div className="flex flex-col items-center mt-7 xl:mt-12">
        <div className="h-[200px] w-full bg-gray-100 rounded-lg animate-pulse" />
        {/* <div className="mt-7 xl:mt-12 flex gap-5">
          {[1, 2, 3].map((i) => (
            <div key={i}>
              <div className="flex items-center gap-2">
                <div className="h-4 w-1 bg-gray-200 rounded animate-pulse" />
                <div className="h-4 w-28 bg-gray-200 rounded animate-pulse" />
              </div>
              <div className="h-6 w-12 bg-gray-200 rounded mt-2 ml-3 animate-pulse" />
            </div>
          ))}
        </div> */}
      </div>
    </div>
  );
};

export default HalfDonutChartSkeleton;
