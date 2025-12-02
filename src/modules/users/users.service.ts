import { normalizeBigInt } from "../../common/utils/helperMethods";
import prisma from "../../config/database";

type User = Awaited<ReturnType<typeof prisma.users.findUnique>>;
type UserCreateInput = Parameters<typeof prisma.users.create>[0]["data"];
type UserUpdateInput = Parameters<typeof prisma.users.update>[0]["data"];

export const createUser = async (
  data: UserCreateInput
): Promise<NonNullable<User>> => {
  return await prisma.users.create({ data });
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

  const where: any = {};

  if (role) {
    where.role = role;
  }

  if (membershipTier) {
    where.memberships = {
      some: {
        membership: {
          tier: membershipTier,
        },
      },
    };
  }

  if (search) {
    where.OR = [
      { first_name: { contains: search, mode: "insensitive" } },
      { last_name: { contains: search, mode: "insensitive" } },
      { email: { contains: search, mode: "insensitive" } },
      { phone: { contains: search, mode: "insensitive" } },
    ];
  }

  const orderBy: any = {};
  if (["first_name", "last_name", "email", "created_at"].includes(sortBy)) {
    orderBy[sortBy] = sortOrder || "desc";
  } else {
    orderBy.created_at = "desc";
  }

  const skip = (page - 1) * limit;

  const total = await prisma.users.count({ where });

  const users = await prisma.users.findMany({
    where,
    select: {
      id: true,
      first_name: true,
      last_name: true,
      email: true,
      phone: true,
      role: true,
      created_at: true,
      updated_at: true,
      memberships: {
        select: {
          membership: {
            select: {
              tier: true,
            },
          },
        },
      },
    },
    orderBy,
    skip,
    take: limit,
  });

  // Safely normalize BigInt fields to string before returning
  const safeUsers = users.map(normalizeBigInt);

  return {
    users: safeUsers,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
};

export const getUserById = async (id: number): Promise<User> => {
  const user = await prisma.users.findUnique({
    where: { id },
    include: { sessions_owned: true, attendees: true },
  });
  return normalizeBigInt(user);
};

export const updateUser = async (
  id: number,
  data: UserUpdateInput
): Promise<NonNullable<User>> => {
  return await prisma.users.update({
    where: { id },
    data,
  });
};
