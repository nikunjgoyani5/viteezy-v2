import FaqsPage from "@/components/faqs";
import { PageHeader } from "@/components/layout/PageHeader";

const Faqs = () => {
  return (
    <div>
      {/* <PageHeader
        title="FAQs"
        actions={
          <Button variant="teal">
            <MdOutlineAdd size={21} />
            Add Question
          </Button>
        }
      /> */}
      <FaqsPage />
    </div>
  );
};

export default Faqs;
