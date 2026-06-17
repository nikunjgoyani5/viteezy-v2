"use client";

import React from "react";
import { ColumnDef } from "@tanstack/react-table";
import { DataTable } from "@/components/ui/table";
import { ToggleSwitch } from "@/components/ui/table/ToggleSwitch";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { Checkbox } from "@/components/ui/table/Checkbox";
import { MdEdit, MdDelete, MdVisibility } from "react-icons/md";
import Image from "next/image";

// ============================================
// TABLE 1: BLOG TABLE
// ============================================
interface Blog {
  id: string;
  title: string;
  category: string;
  status: boolean;
  updated: string;
  created: string;
  image: string;
}

const blogData: Blog[] = [
  {
    id: "1",
    title: "Are blueberries healthy? Here are the 6 benefits!",
    category: "Power supply",
    status: true,
    updated: "Jun 17, 2024",
    created: "Dec 11, 2023",
    image: "/images/blog-1.jpg",
  },
  {
    id: "2",
    title: "Are blueberries healthy? Here are the 6 benefits!",
    category: "Lifestyle",
    status: true,
    updated: "Jun 17, 2024",
    created: "Dec 11, 2023",
    image: "/images/blog-2.jpg",
  },
  {
    id: "3",
    title: "Are blueberries healthy? Here are the 6 benefits!",
    category: "Power supply",
    status: true,
    updated: "Jun 17, 2024",
    created: "Dec 11, 2023",
    image: "/images/blog-3.jpg",
  },
  {
    id: "4",
    title: "Are blueberries healthy? Here are the 6 benefits!",
    category: "Health",
    status: true,
    updated: "Jun 17, 2024",
    created: "Dec 11, 2023",
    image: "/images/blog-4.jpg",
  },
  {
    id: "5",
    title: "Are blueberries healthy? Here are the 6 benefits!",
    category: "Lifestyle",
    status: true,
    updated: "Jun 17, 2024",
    created: "Dec 11, 2023",
    image: "/images/blog-5.jpg",
  },
  {
    id: "6",
    title: "Are blueberries healthy? Here are the 6 benefits!",
    category: "Vitamins",
    status: true,
    updated: "Jun 17, 2024",
    created: "Dec 11, 2023",
    image: "/images/blog-6.jpg",
  },
];

// ============================================
// TABLE 2: CATEGORY TABLE
// ============================================
interface Category {
  id: string;
  title: string;
  blog: number;
}

const categoryData: Category[] = [
  { id: "1", title: "Lifestyle", blog: 8 },
  { id: "2", title: "Vitamins", blog: 10 },
  { id: "3", title: "Power supply", blog: 6 },
  { id: "4", title: "Health", blog: 14 },
];

// ============================================
// TABLE 3: INGREDIENTS TABLE
// ============================================
interface Ingredient {
  id: string;
  name: string;
  description: string;
  linkedProducts: number;
  status: boolean;
  image: string;
}

const ingredientData: Ingredient[] = [
  {
    id: "1",
    name: "Chorella",
    description:
      "Grown in Oldenzaal (the Netherlands) in closed fermentation tanks for the highest ...",
    linkedProducts: 5,
    status: true,
    image: "/images/ingredient-1.jpg",
  },
  {
    id: "2",
    name: "Lithothamnion",
    description:
      "Collected along the coast of Iceland, exclusively from naturally occurring seaweed, ...",
    linkedProducts: 5,
    status: true,
    image: "/images/ingredient-2.jpg",
  },
  {
    id: "3",
    name: "Spirulina",
    description:
      "Grown in Catalonia (Spain) and dried at a low temperature to preserve nutritional value,...",
    linkedProducts: 5,
    status: true,
    image: "/images/ingredient-3.jpg",
  },
  {
    id: "4",
    name: "Wakame",
    description:
      "Grown in Brittany, France, in a protected marine ecosystem, wakame is a natural source...",
    linkedProducts: 5,
    status: true,
    image: "/images/ingredient-4.jpg",
  },
];

const Table1Page = () => {
  // ============================================
  // BLOG TABLE COLUMNS
  // ============================================
  const blogColumns: ColumnDef<Blog>[] = [
    {
      id: "select",
      header: ({ table }) => (
        <Checkbox
          checked={table.getIsAllPageRowsSelected()}
          indeterminate={table.getIsSomePageRowsSelected()}
          onChange={(value) => table.toggleAllPageRowsSelected(!!value)}
        />
      ),
      cell: ({ row }) => (
        <Checkbox
          checked={row.getIsSelected()}
          onChange={(value) => row.toggleSelected(!!value)}
        />
      ),
      enableSorting: false,
      enableHiding: false,
    },
    {
      accessorKey: "title",
      header: "Title",
      cell: ({ row }) => {
        const blog = row.original;
        return (
          <div className="flex items-center gap-3">
            <div className="h-12 w-12 rounded-lg overflow-hidden bg-gray-100 shrink-0">
              <Image
                src={blog.image}
                alt={blog.title}
                width={48}
                height={48}
                className="h-full w-full object-cover"
              />
            </div>
            <span className="font-medium text-gray-900">{blog.title}</span>
          </div>
        );
      },
    },
    {
      accessorKey: "category",
      header: "Category",
      cell: ({ row }) => (
        <span className="text-gray-700">{row.getValue("category")}</span>
      ),
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => (
        <ToggleSwitch
          checked={row.getValue("status")}
          onChange={(checked) => {
            console.log("Blog status changed:", checked);
          }}
        />
      ),
    },
    {
      accessorKey: "updated",
      header: "Updated",
      cell: ({ row }) => (
        <span className="text-gray-700">{row.getValue("updated")}</span>
      ),
    },
    {
      accessorKey: "created",
      header: "Create",
      cell: ({ row }) => (
        <span className="text-gray-700">{row.getValue("created")}</span>
      ),
    },
    {
      id: "actions",
      header: "Actions",
      cell: ({ row }) => {
        const blog = row.original;
        return (
          <ActionMenu
            items={[
              {
                label: "Edit",
                icon: <MdEdit className="h-4 w-4" />,
                onClick: () => console.log("Edit blog", blog.id),
              },
              {
                label: "Delete",
                icon: <MdDelete className="h-4 w-4" />,
                onClick: () => console.log("Delete blog", blog.id),
                danger: true,
              },
            ]}
          />
        );
      },
    },
  ];

  // ============================================
  // CATEGORY TABLE COLUMNS
  // ============================================
  const categoryColumns: ColumnDef<Category>[] = [
    {
      id: "select",
      header: ({ table }) => (
        <Checkbox
          checked={table.getIsAllPageRowsSelected()}
          indeterminate={table.getIsSomePageRowsSelected()}
          onChange={(value) => table.toggleAllPageRowsSelected(!!value)}
        />
      ),
      cell: ({ row }) => (
        <Checkbox
          checked={row.getIsSelected()}
          onChange={(value) => row.toggleSelected(!!value)}
        />
      ),
      enableSorting: false,
      enableHiding: false,
    },
    {
      accessorKey: "title",
      header: "Title",
      cell: ({ row }) => (
        <span className="font-medium text-gray-900">
          {row.getValue("title")}
        </span>
      ),
    },
    {
      accessorKey: "blog",
      header: "Blog",
      cell: ({ row }) => (
        <span className="text-gray-700">{row.getValue("blog")}</span>
      ),
    },
    {
      id: "actions",
      header: "Actions",
      cell: ({ row }) => {
        const category = row.original;
        return (
          <ActionMenu
            items={[
              {
                label: "Edit",
                icon: <MdEdit className="h-4 w-4" />,
                onClick: () => console.log("Edit category", category.id),
              },
              {
                label: "Delete",
                icon: <MdDelete className="h-4 w-4" />,
                onClick: () => console.log("Delete category", category.id),
                danger: true,
              },
            ]}
          />
        );
      },
    },
  ];

  // ============================================
  // INGREDIENTS TABLE COLUMNS
  // ============================================
  const ingredientColumns: ColumnDef<Ingredient>[] = [
    {
      accessorKey: "name",
      header: "Ingredient",
      cell: ({ row }) => {
        const ingredient = row.original;
        return (
          <div className="flex items-center gap-3">
            <div className="h-10 w-10 rounded-lg overflow-hidden bg-gray-100 shrink-0">
              <Image
                src={ingredient.image}
                alt={ingredient.name}
                width={40}
                height={40}
                className="h-full w-full object-cover"
              />
            </div>
            <span className="font-medium text-gray-900">{ingredient.name}</span>
          </div>
        );
      },
    },
    {
      accessorKey: "description",
      header: "Description",
      cell: ({ row }) => (
        <div className="max-w-md">
          <p className="text-gray-700 text-sm line-clamp-2">
            {row.getValue("description")}
          </p>
        </div>
      ),
    },
    {
      accessorKey: "linkedProducts",
      header: "Linked Products",
      cell: ({ row }) => (
        <span className="text-gray-700">
          {row.getValue("linkedProducts")} Products
        </span>
      ),
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => (
        <ToggleSwitch
          checked={row.getValue("status")}
          onChange={(checked) => {
            console.log("Ingredient status changed:", checked);
          }}
        />
      ),
    },
    {
      id: "actions",
      header: "Actions",
      cell: ({ row }) => {
        const ingredient = row.original;
        return (
          <ActionMenu
            items={[
              {
                label: "View",
                icon: <MdVisibility className="h-4 w-4" />,
                onClick: () => console.log("View ingredient", ingredient.id),
              },
              {
                label: "Edit",
                icon: <MdEdit className="h-4 w-4" />,
                onClick: () => console.log("Edit ingredient", ingredient.id),
              },
              {
                label: "Delete",
                icon: <MdDelete className="h-4 w-4" />,
                onClick: () => console.log("Delete ingredient", ingredient.id),
                danger: true,
              },
            ]}
          />
        );
      },
    },
  ];

  return (
    <div className="p-6 space-y-12">
      {/* TABLE 1: BLOG */}
      <div>
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">All Blog</h1>
        </div>
        <DataTable
          columns={blogColumns}
          data={blogData}
          searchKey="title"
          searchPlaceholder="Searching all blog"
          filters={[
            { value: "all", label: "All" },
            { value: "active", label: "Active" },
            { value: "inactive", label: "Inactive" },
          ]}
          pageSize={10}
        />
      </div>

      {/* TABLE 2: CATEGORY */}
      <div>
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">All Category</h1>
        </div>
        <DataTable
          columns={categoryColumns}
          data={categoryData}
          searchKey="title"
          searchPlaceholder="Searching all category"
          pageSize={10}
        />
      </div>

      {/* TABLE 3: INGREDIENTS */}
      <div>
        <div className="mb-6">
          <h1 className="text-2xl font-bold text-gray-900">All Ingredients</h1>
        </div>
        <DataTable
          columns={ingredientColumns}
          data={ingredientData}
          searchKey="name"
          searchPlaceholder="Searching all ingredients"
          filters={[
            { value: "all", label: "All" },
            { value: "active", label: "Active" },
            { value: "inactive", label: "Inactive" },
          ]}
          pageSize={10}
        />
      </div>
    </div>
  );
};

export default Table1Page;
