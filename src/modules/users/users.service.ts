import prisma from "../../config/database";

type User = Awaited<ReturnType<typeof prisma.user.findUnique>>;
type UserCreateInput = Parameters<typeof prisma.user.create>[0]["data"];
type UserUpdateInput = Parameters<typeof prisma.user.update>[0]["data"];

export const createUser = async (
  data: UserCreateInput
): Promise<NonNullable<User>> => {
  return await prisma.user.create({ data });
};

type GetAllUsersOptions = {
  page: number;
  limit: number;
  role?: string;
  membershipTier?: string;
  search?: string;
  sortBy: string;
  sortOrder: "asc" | "desc";
};

export const getAllUsers = async (options: GetAllUsersOptions) => {
  const { page, limit, role, membershipTier, search, sortBy, sortOrder } =
    options;

  // Build where clause for filtering
  const where: any = {};

  if (role) {
    where.role = role;
  }

  if (membershipTier) {
    where.membershipTier = membershipTier;
  }

  if (search) {
    where.OR = [
      { name: { contains: search, mode: "insensitive" } },
      { email: { contains: search, mode: "insensitive" } },
      { phoneNumber: { contains: search, mode: "insensitive" } },
    ];
  }

  // Build orderBy clause
  const orderBy: any = {};
  if (sortBy === "name" || sortBy === "email" || sortBy === "createdAt") {
    orderBy[sortBy] = sortOrder;
  } else {
    orderBy.createdAt = "desc"; // Default fallback
  }

  // Calculate pagination
  const skip = (page - 1) * limit;

  // Get total count for pagination
  const total = await prisma.user.count({ where });

  // Fetch users with pagination
  const users = await prisma.user.findMany({
    where,
    select: {
      id: true,
      name: true,
      email: true,
      phoneNumber: true,
      role: true,
      membershipTier: true,
      membershipExpiry: true,
      createdAt: true,
      updatedAt: true,
    },
    orderBy,
    skip,
    take: limit,
  });

  const totalPages = Math.ceil(total / limit);

  return {
    users,
    pagination: {
      page,
      limit,
      total,
      totalPages,
    },
  };
};

export const getUserById = async (id: string): Promise<User> => {
  return await prisma.user.findUnique({
    where: { id },
    include: { guruProfile: true },
  });
};

export const updateUser = async (
  id: string,
  data: UserUpdateInput
): Promise<NonNullable<User>> => {
  return await prisma.user.update({
    where: { id },
    data,
  });
};
