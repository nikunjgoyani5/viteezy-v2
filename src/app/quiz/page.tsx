import MainLayout from "@/components/layouts/MainLayout";
import QuizBase from "@/components/quiz";

const Quiz = () => {
  return (
    <MainLayout isFooter={false} headerClassName="border-b border-slate-border-color">
      <div className="h-[calc(100vh-117px)] bg-off-white-color">
        <QuizBase />
      </div>
    </MainLayout>
  );
};

export default Quiz;
