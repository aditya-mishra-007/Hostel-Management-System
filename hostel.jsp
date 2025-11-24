<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // Fetch session attributes to determine user role and identity
    String admin = (String)session.getAttribute("admin");
    String student = (String)session.getAttribute("student");

    // Determine the active role and primary color theme
    String role = null;
    String primaryColor = "indigo"; // Default to student/guest theme
    String primaryColorHex = "#4f46e5"; // Indigo-600
    String greetingName = "Guest";

    if (admin != null) {
        role = "admin";
        primaryColor = "teal";
        primaryColorHex = "#0d9488"; // Teal-600
        greetingName = admin;
    } else if (student != null) {
        role = "student";
        primaryColor = "indigo";
        primaryColorHex = "#4f46e5"; // Indigo-600
        // Assuming student holds the Roll Number, format the name for display
        greetingName = "Roll No: " + student;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Hostel Management</title>
    <!-- Load Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Load Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* Define dynamic primary color based on role for custom elements */
        .header-bg {
            background-color: <%= primaryColorHex %>;
        }
        .text-primary {
            color: <%= primaryColorHex %>;
        }
        .btn-primary {
            background-color: <%= primaryColorHex %>;
            transition: background-color 0.2s, transform 0.2s;
        }
        .btn-primary:hover {
            background-color: <%= role.equals("admin") ? "#0f766e" : "#4338ca" %>; /* Darker shade on hover */
            transform: translateY(-1px);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }
        .card-link {
             transition: all 0.2s ease-in-out;
             border-left: 4px solid #e5e7eb;
        }
        .card-link:hover {
             border-left: 4px solid <%= primaryColorHex %>;
             background-color: <%= role.equals("admin") ? "#f0fdfa" : "#eef2ff" %>; /* Light hover background */
             transform: translateX(4px);
        }
        /* Ensure font consistency */
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f3f4f6;
        }
    </style>
</head>
<body class="min-h-screen">

    <!-- Navbar Header -->
    <header class="header-bg shadow-lg">
        <div class="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
            <h1 class="text-xl font-bold text-white tracking-wide flex items-center space-x-2">
                <i data-lucide="building" class="h-6 w-6"></i>
                <span>Hostel Portal</span>
            </h1>

            <% if (role != null) { %>
                <div class="flex items-center space-x-4">
                    <span class="text-sm font-medium text-white/90 hidden sm:block">
                        Logged in as: <%= greetingName %>
                    </span>
                    <a href="logout.jsp" class="text-white bg-red-600 hover:bg-red-700 text-sm py-2 px-4 rounded-lg font-semibold shadow-md flex items-center space-x-2">
                         <i data-lucide="log-out" class="h-4 w-4"></i>
                         <span>Logout</span>
                    </a>
                </div>
            <% } %>
        </div>
    </header>

    <!-- Main Content Area -->
    <main class="max-w-6xl mx-auto p-4 sm:p-6 lg:p-8">

        <div class="bg-white p-8 rounded-xl shadow-2xl space-y-8">

            <% if (role != null) { %>
                <!-- Logged In State -->
                <header class="pb-4 border-b border-gray-200">
                    <h2 class="text-3xl font-extrabold text-gray-800">
                        Welcome back, <span class="text-primary"><%= role.equals("admin") ? "Administrator" : "Student" %></span>
                    </h2>
                    <p class="text-lg text-gray-500 mt-1">Your quick action links are below.</p>
                </header>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                    <% if (role.equals("admin")) { %>
                        <!-- Admin Links (Teal Theme) -->
                        <a href="view_students.jsp" class="card-link flex items-center p-6 rounded-xl bg-gray-50 shadow-md">
                            <i data-lucide="users" class="h-8 w-8 text-teal-600 mr-4"></i>
                            <div>
                                <h3 class="text-xl font-semibold text-gray-800">View All Students</h3>
                                <p class="text-sm text-gray-500">Access full student directory and profiles.</p>
                            </div>
                        </a>
                        <a href="manage_rooms.jsp" class="card-link flex items-center p-6 rounded-xl bg-gray-50 shadow-md">
                            <i data-lucide="building-2" class="h-8 w-8 text-teal-600 mr-4"></i>
                            <div>
                                <h3 class="text-xl font-semibold text-gray-800">Manage Rooms & Beds</h3>
                                <p class="text-sm text-gray-500">Update capacity and allocate rooms.</p>
                            </div>
                        </a>
                        <a href="pending_requests.jsp" class="card-link flex items-center p-6 rounded-xl bg-gray-50 shadow-md">
                            <i data-lucide="bell" class="h-8 w-8 text-teal-600 mr-4"></i>
                            <div>
                                <h3 class="text-xl font-semibold text-gray-800">Pending Leave Requests</h3>
                                <p class="text-sm text-gray-500">Review and approve/reject outpass applications.</p>
                            </div>
                        </a>
                        <a href="fee_reports.jsp" class="card-link flex items-center p-6 rounded-xl bg-gray-50 shadow-md">
                            <i data-lucide="wallet" class="h-8 w-8 text-teal-600 mr-4"></i>
                            <div>
                                <h3 class="text-xl font-semibold text-gray-800">Fee Management</h3>
                                <p class="text-sm text-gray-500">View outstanding balances and financial reports.</p>
                            </div>
                        </a>
                    <% } else { %>
                        <!-- Student Links (Indigo Theme) -->
                        <a href="attendance.jsp?roll=<%= student %>" class="card-link flex items-center p-6 rounded-xl bg-gray-50 shadow-md">
                            <i data-lucide="calendar-check" class="h-8 w-8 text-indigo-600 mr-4"></i>
                            <div>
                                <h3 class="text-xl font-semibold text-gray-800">View Attendance</h3>
                                <p class="text-sm text-gray-500">Check your current attendance status.</p>
                            </div>
                        </a>
                        <a href="submit_leave.jsp" class="card-link flex items-center p-6 rounded-xl bg-gray-50 shadow-md">
                            <i data-lucide="send" class="h-8 w-8 text-indigo-600 mr-4"></i>
                            <div>
                                <h3 class="text-xl font-semibold text-gray-800">Submit Leave Request</h3>
                                <p class="text-sm text-gray-500">Apply for an official outpass.</p>
                            </div>
                        </a>
                         <a href="view_room.jsp" class="card-link flex items-center p-6 rounded-xl bg-gray-50 shadow-md">
                            <i data-lucide="bed-single" class="h-8 w-8 text-indigo-600 mr-4"></i>
                            <div>
                                <h3 class="text-xl font-semibold text-gray-800">My Room & Roommates</h3>
                                <p class="text-sm text-gray-500">View allocation details.</p>
                            </div>
                        </a>
                        <a href="fee_details.jsp" class="card-link flex items-center p-6 rounded-xl bg-gray-50 shadow-md">
                            <i data-lucide="credit-card" class="h-8 w-8 text-indigo-600 mr-4"></i>
                            <div>
                                <h3 class="text-xl font-semibold text-gray-800">Fee Payment</h3>
                                <p class="text-sm text-gray-500">Check balance and pay online.</p>
                            </div>
                        </a>
                    <% } %>
                </div>

            <% } else { %>
                <!-- Not Logged In State -->
                <div class="p-10 text-center bg-red-50 border border-red-200 rounded-xl shadow-inner">
                    <i data-lucide="lock" class="h-12 w-12 text-red-500 mx-auto mb-4"></i>
                    <h2 class="text-2xl font-bold text-red-700">Access Denied</h2>
                    <p class="mt-2 text-gray-600">You must be logged in as an Administrator or Student to view this dashboard.</p>
                    <a href="index_enhanced.html" class="mt-6 inline-flex items-center justify-center py-3 px-6 text-white bg-red-600 hover:bg-red-700 rounded-lg font-semibold transition-colors shadow-md">
                         <i data-lucide="home" class="h-5 w-5 mr-2"></i>
                         <span>Go to Login Selection</span>
                    </a>
                </div>
            <% } %>
        </div>

    </main>

    <!-- Re-initialize Lucide Icons -->
    <script>
        lucide.createIcons();
    </script>
</body>
</html>