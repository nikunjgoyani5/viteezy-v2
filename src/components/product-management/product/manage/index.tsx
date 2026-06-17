import ProductForm from "./ProductForm";

const ManageProductPage = ({
  mode,
  id,
}: {
  mode: "create" | "edit";
  id?: string;
}) => {
  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <div className="form-container mx-auto">
        <ProductForm mode={mode} id={id} />
      </div>
    </div>
  );
};

export default ManageProductPage;