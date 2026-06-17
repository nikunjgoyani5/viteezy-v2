import { Doughnut } from "react-chartjs-2";
import { Chart as ChartJS, ArcElement, Tooltip, TooltipItem } from "chart.js";

const COLORS = [
  "#4896FE",
  "#16C8C7",
  "#67E9E9",
  "#1BAF9A",
  "#34D399",
  "#60A5FA",
] as const;

ChartJS.register(ArcElement, Tooltip);

const HalfDonutChart = ({
  series,
  labels,
}: {
  series: string[] | number[];
  labels: string[];
}) => {
  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: { display: false },
      tooltip: {
        callbacks: {
          label: (context: TooltipItem<"doughnut">) => `${context.parsed}%`,
        },
      },
    },
  };

  const data = {
    labels,
    datasets: [
      {
        data: series,
        backgroundColor: COLORS as unknown as string[],
        borderColor: "#ffffff",
        borderWidth: 3,
        borderRadius: 10,
        cutout: "68%",
        rotation: -90,
        circumference: 180,
        // spacing: 6,
      },
    ],
  };

  return (
    <div className="flex flex-col items-center mt-7 xl:mt-12 h-full">
      <div className="relative  h-50  w-95">
        <div className=" absolute  -top-1 start-1/2 -translate-x-1/2 w-[calc(100%+8px)] h-[calc(100%-5px)] border-b-0 translate-1 rounded-t-full border "></div>
        <Doughnut data={data} options={options} />
      </div>
      <div className="mt-7 xl:mt-12 flex flex-wrap justify-center gap-7 max-w-xl 3xl:min-w-xl">
        {labels.map((label, i) => (
          // <div key={label} className=" items-end justify-between gap-3 w-full sm:basis-[calc(33.333%-1.166rem)] max-w-[calc(33.333%-1.166rem)]">
          <div key={label} className=" items-end justify-between gap-3 w-full sm:basis-[calc(33.333%-1.166rem)]">
            <div className="flex items-center gap-2 min-w-0">
              <span
                className="h-4 w-0.75 shrink-0  rounded-md"
                style={{ backgroundColor: COLORS[i % COLORS.length] }}
              />
              <span className="text-sm xl:text-base text-text-gray font-medium truncate leading-tight">
                {label}
              </span>
            </div>

            <span className="text-base font-medium text-black xl:text-2xl ms-3">
              {series[i] ?? 0}%
            </span>
          </div>
        ))}
      </div>
      {!series?.length && (
        <span className="text-text-gray">No data found for applied filter</span>
      )}
    </div>
  );
};

export default HalfDonutChart;
