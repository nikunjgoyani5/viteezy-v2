import IngredientsManagmentPage from "@/components/ingredients-management";
import { PageHeader } from "@/components/layout/PageHeader";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import Link from "next/link";
import React, { Suspense } from "react";
import { MdOutlineAdd } from "react-icons/md";

const IngredientsManagment = () => {
  return (
    <div>
      <PageHeader
        title="Ingredients Management"
        actions={
          <Link href={ROUTES.INGREDIENTS_MANAGMENT.CREATE_INGREDIENT}>
            <Button variant="teal" className="text-sm 3xl:text-base">
              <MdOutlineAdd size={20} />
              Add Ingredients
            </Button>
          </Link>
        }
      />
      <Suspense fallback={null}>
        <IngredientsManagmentPage />
      </Suspense>
    </div>
  );
};

export default IngredientsManagment;
