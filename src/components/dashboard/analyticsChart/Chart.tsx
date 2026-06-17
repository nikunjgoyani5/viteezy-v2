import {
  CategoryScale,
  ChartData,
  ChartOptions,
  Filler,
  Legend,
  LineElement,
  LinearScale,
  Plugin,
  PointElement,
  Tooltip,
} from "chart.js";
import React from "react";
import { Line } from "react-chartjs-2";

import { Chart as ChartJS } from "chart.js";
import { formatCurrencyCompact } from "@/lib/common";

const primary = "#1BAF9A";
const white = "#FFFFFF";
const border = "#ebebeb";
const black = "#141414";

ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Tooltip,
  Legend,
  Filler
);

// dashed horizontal grid (background)
const dashedYGridPlugin: Plugin<"line"> = {
  id: "dashedYGrid",
  beforeDatasetsDraw(chart) {
    const { ctx, chartArea, scales } = chart;
    const y = scales.y;
    if (!y) return;

    ctx.save();
    ctx.strokeStyle = border;
    ctx.lineWidth = 1;
    ctx.setLineDash([6, 3]);
    ctx.lineDashOffset = 0;

    y.ticks.forEach((_t, i) => {
      const yPixel = y.getPixelForTick(i);
      if (yPixel < chartArea.top || yPixel > chartArea.bottom) return;

      ctx.beginPath();
      ctx.moveTo(chartArea.left, yPixel);
      ctx.lineTo(chartArea.right, yPixel);
      ctx.stroke();
    });

    ctx.restore();
  },
};

ChartJS.register(dashedYGridPlugin);

const Chart = ({
  values,
  labels,
}: {
  values?: string[] | number[];
  labels?: string[];
}) => {
  const theme = React.useMemo(() => {
    if (typeof window === "undefined") return primary;
    const v = getComputedStyle(document.documentElement)
      .getPropertyValue("--color-secondary")
      .trim();
    return v || primary;
  }, []);

  const numericValues = React.useMemo(
    () => values?.map((v) => Number(v)) ?? [],
    [values]
  );

  const chartData = React.useMemo<ChartData<"line", number[], string>>(
    () => ({
      labels: labels ?? [],
      datasets: [
        {
          label: "Revenue",
          data: numericValues,
          borderColor: theme,
          backgroundColor: primary + "18",
          borderWidth: 2,
          pointBackgroundColor: theme,
          pointBorderColor: white,
          pointBorderWidth: 2,
          pointRadius: 6,
          pointHoverRadius: 8,
          fill: true,
          tension: 0,
        },
      ],
    }),
    [theme, labels, numericValues]
  );

  const options = React.useMemo<ChartOptions<"line">>(
    () => ({
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: "index", intersect: false },

      plugins: {
        legend: { display: false },
        tooltip: {
          mode: "index",
          intersect: false,
          displayColors: false,
          backgroundColor: white,
          titleColor: black,
          bodyColor: primary,
          padding: 12,
          borderColor: border,
          borderWidth: 1,
          cornerRadius: 6,

          bodyFont: { size: 14, weight: 500 },
          titleFont: { size: 12, weight: 500 },

          callbacks: {
            label(context) {
              const y = context.parsed.y;
              if (typeof y !== "number") {
                return "Amount: —";
              }
              return `Amount: ${formatCurrencyCompact(y)}`;
            },
          },
        },
      },

      layout: { padding: 24 },

      scales: {
        x: {
          grid: { display: false },
          border: { display: false },
        },
        y: {
          beginAtZero: true,
          ticks: {
            callback(value) {
              return typeof value === "number"
                ? formatCurrencyCompact(value)
                : value;
            },
          },
        },
      },
    }),
    []
  );

  return <Line data={chartData} options={options} />;
};

export default Chart;
