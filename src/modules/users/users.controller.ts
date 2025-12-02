import { Request, Response } from "express";
import * as UsersService from "./users.service";

export const createUser = async (req: Request, res: Response) => {
  try {
    const user = await UsersService.createUser(req.body);
    res.status(201).json({ success: true, data: user });
  } catch (error: any) {
    res.status(400).json({ success: false, error: error.message });
  }
};

export const getAllUsers = async (req: Request, res: Response) => {
  try {
    // Extract query parameters
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const role = req.query.role as string | undefined;
    const membershipTier = req.query.membershipTier as string | undefined;
    const search = req.query.search as string | undefined;
    const sortBy = (req.query.sortBy as string) || "createdAt";
    const sortOrder = (req.query.sortOrder as "asc" | "desc") || "desc";

    // Validate pagination
    if (page < 1) {
      return res.status(400).json({
        success: false,
        error: "Page number must be greater than 0",
      });
    }

    if (limit < 1 || limit > 100) {
      return res.status(400).json({
        success: false,
        error: "Limit must be between 1 and 100",
      });
    }

    // Call service with filters
    const result = await UsersService.getAllUsers({
      page,
      limit,
      role,
      membershipTier,
      search,
      sortBy,
      sortOrder,
    });

    res.json({
      success: true,
      data: result.users,
      pagination: {
        page: result.pagination.page,
        limit: result.pagination.limit,
        total: result.pagination.total,
        totalPages: result.pagination.totalPages,
      },
    });
  } catch (error: any) {
    console.error("Error fetching users:", error);
    res.status(500).json({
      success: false,
      error: error.message || "Failed to fetch users",
    });
  }
};

export const getUserProfile = async (req: Request, res: Response) => {
  try {
    const user = await UsersService.getUserById(req.params.id);
    if (!user) {
      return res.status(404).json({ success: false, error: "User not found" });
    }
    res.json({ success: true, data: user });
  } catch (error: any) {
    res.status(500).json({ success: false, error: error.message });
  }
};

export const updateUserProfile = async (req: Request, res: Response) => {
  try {
    const user = await UsersService.updateUser(req.params.id, req.body);
    res.json({ success: true, data: user });
  } catch (error: any) {
    res.status(400).json({ success: false, error: error.message });
  }
};
