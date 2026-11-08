import React, { useState } from 'react';
import { Head, useForm, router } from '@inertiajs/react';
import AppLayout from '@/layouts/app-layout';
import { type BreadcrumbItem } from '@/types';


const breadcrumbs: BreadcrumbItem[] = [
    {
        title: 'Categories',
        href: '/categories',
    },
];


// Define TypeScript interfaces
export interface Category {
    id: number;
    name: string;
    slug: string;
    description: string | null;
    created_at?: string;
    updated_at?: string;
}

export interface PaginationLink {
    url: string | null;
    label: string;
    active: boolean;
}

export interface PaginatedCategories {
    data: Category[];
    links: PaginationLink[];
    current_page: number;
    last_page: number;
    from: number | null;
    to: number | null;
    total: number;
}

interface Props {
    auth: {
        user: {
            id: number;
            name: string;
            email: string;
            [key: string]: any;
        };
    };
    categories: PaginatedCategories;
    [key: string]: any;
}

export default function Index({ auth, categories }: Props) {
    const [isModalOpen, setIsModalOpen] = useState<boolean>(false);
    const [editingCategory, setEditingCategory] = useState<Category | null>(null);

    const { data, setData, post, put, processing, errors, reset, clearErrors } = useForm({
        name: '',
        description: '',
    });

    const openCreateModal = () => {
        setEditingCategory(null);
        reset();
        clearErrors();
        setIsModalOpen(true);
    };

    const openEditModal = (category: Category) => {
        setEditingCategory(category);
        setData({
            name: category.name,
            description: category.description || '',
        });
        clearErrors();
        setIsModalOpen(true);
    };

    const closeModal = () => {
        setIsModalOpen(false);
        reset();
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (editingCategory) {
            put(route('categories.update', editingCategory.id), {
                onSuccess: () => closeModal(),
            });
        } else {
            post(route('categories.store'), {
                onSuccess: () => closeModal(),
            });
        }
    };

    const handleDelete = (category: Category) => {
        if (confirm(`Are you sure you want to delete "${category.name}"?`)) {
            router.delete(route('categories.destroy', category.id));
        }
    };

    return (
        
       <AppLayout breadcrumbs={breadcrumbs}>
            <Head title="Categories" />

            <div className="py-12">
                <div className="max-w-7xl mx-auto sm:px-6 lg:px-8">
                    <div className="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                        
                        <div className="flex justify-between items-center mb-6">
                            <h3 className="text-lg font-medium text-gray-900">All Categories</h3>
                            <button
                                onClick={openCreateModal}
                                className="bg-indigo-600 hover:bg-indigo-700 text-white px-4 py-2 rounded-md text-sm font-medium transition"
                            >
                                Add Category
                            </button>
                        </div>

                        {/* Categories Table */}
                        <div className="overflow-x-auto">
                            <table className="min-w-full divide-y divide-gray-200">
                                <thead className="bg-gray-50">
                                    <tr>
                                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Slug</th>
                                        <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Description</th>
                                        <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                    </tr>
                                </thead>
                                <tbody className="bg-white divide-y divide-gray-200">
                                    {categories.data.length > 0 ? (
                                        categories.data.map((category) => (
                                            <tr key={category.id}>
                                                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{category.name}</td>
                                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{category.slug}</td>
                                                <td className="px-6 py-4 text-sm text-gray-500">{category.description || '—'}</td>
                                                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                                                    <button
                                                        onClick={() => openEditModal(category)}
                                                        className="text-indigo-600 hover:text-indigo-900 mr-4"
                                                    >
                                                        Edit
                                                    </button>
                                                    <button
                                                        onClick={() => handleDelete(category)}
                                                        className="text-red-600 hover:text-red-900"
                                                    >
                                                        Delete
                                                    </button>
                                                </td>
                                            </tr>
                                        ))
                                    ) : (
                                        <tr>
                                            <td colSpan={4} className="px-6 py-4 text-center text-sm text-gray-500">
                                                No categories found.
                                            </td>
                                        </tr>
                                    )}
                                </tbody>
                            </table>
                        </div>

                        {/* Pagination Links */}
                        <div className="mt-4 flex flex-wrap gap-1 justify-between items-center">
                            {categories.links && categories.links.map((link, index) => (
                                <button
                                    key={index}
                                    disabled={!link.url}
                                    onClick={() => link.url && router.visit(link.url)}
                                    dangerouslySetInnerHTML={{ __html: link.label }}
                                    className={`px-3 py-1 border rounded text-sm ${
                                        link.active ? 'bg-indigo-600 text-white' : 'bg-white text-gray-700'
                                    } ${!link.url ? 'opacity-50 cursor-not-allowed' : ''}`}
                                />
                            ))}
                        </div>

                    </div>
                </div>
            </div>

            {/* Modal for Create/Edit */}
            {isModalOpen && (
                <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50">
                    <div className="bg-white rounded-lg p-6 w-full max-w-md">
                        <h3 className="text-lg font-medium text-gray-900 mb-4">
                            {editingCategory ? 'Edit Category' : 'Create New Category'}
                        </h3>
                        <form onSubmit={handleSubmit}>
                            <div className="mb-4">
                                <label className="block text-sm font-medium text-gray-700">Name</label>
                                <input
                                    type="text"
                                    value={data.name}
                                    onChange={(e) => setData('name', e.target.value)}
                                    className="mt-1 block w-full text-gray-900 rounded-md p-2.5 border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                                    required
                                />
                                {errors.name && <div className="text-red-600 text-sm mt-1">{errors.name}</div>}
                            </div>

                            <div className="mb-4">
                                <label className="block text-sm font-medium text-gray-700">Description</label>
                                <textarea
                                    value={data.description}
                                    onChange={(e) => setData('description', e.target.value)}
                                    className="mt-1 block w-full rounded-md border-gray-300 text-gray-700 p-3 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                                    rows={3}
                                ></textarea>
                                {errors.description && <div className="text-red-600 text-sm mt-1">{errors.description}</div>}
                            </div>

                            <div className="flex justify-end space-x-3">
                                <button
                                    type="button"
                                    onClick={closeModal}
                                    className="bg-gray-200 text-gray-700 px-4 py-2 rounded-md text-sm font-medium hover:bg-gray-300"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    disabled={processing}
                                    className="bg-indigo-600 text-white px-4 py-2 rounded-md text-sm font-medium hover:bg-indigo-700"
                                >
                                    {editingCategory ? 'Update' : 'Create'}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </AppLayout>
    );
}