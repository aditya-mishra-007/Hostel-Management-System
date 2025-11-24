<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String msg = "";

    // --- JDBC Login Logic ---
    if (request.getMethod().equals("POST")) {
        String u = request.getParameter("username");
        String p = request.getParameter("password");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            // Check Database connection prerequisites: Driver, URL, Credentials
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hostel_db",
                    "root",
                    "admin" // <<< CHANGE ADMIN PASSWORD HERE
            );

            // Using Prepared Statement to prevent SQL Injection
            ps = con.prepareStatement(
                    "SELECT username FROM admin WHERE username=? AND password=?"
            );
            ps.setString(1, u);
            ps.setString(2, p);

            rs = ps.executeQuery();

            if (rs.next()) {
                // Login successful
                session.setAttribute("admin", u);
                response.sendRedirect("hostel.jsp"); // Redirect to the main admin dashboard
                return;
            } else {
                // Login failed
                msg = "Invalid Username or Password.";
            }

        } catch (SQLException e) {
            msg = "Database Error: Cannot connect or table 'admin' is missing.";
            System.err.println("SQL Error: " + e.getMessage());
        } catch (ClassNotFoundException e) {
            msg = "System Error: MySQL driver not found.";
            System.err.println("Driver Error: " + e.getMessage());
        } finally {
            // Close resources safely
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (ps != null) ps.close(); } catch (SQLException e) {}
            try { if (con != null) con.close(); } catch (SQLException e) {}
        }
    }
    // --- END JDBC Login Logic ---
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Hostel Management</title>
    <!-- Load Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Load Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* Custom Styles for Professional Look */
        body {
            font-family: 'Inter', sans-serif;
            background-color: #eef2f3; /* Light Gray Background */
        }
        .login-card {
            border-top: 5px solid #0d9488; /* Teal border for admin panel */
            transition: all 0.3s ease-in-out;
        }
        .login-card:hover {
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            transform: translateY(-2px);
        }
        .btn-primary {
            background-color: #0d9488; /* Teal 600 */
            transition: background-color 0.2s;
        }
        .btn-primary:hover {
            background-color: #0f766e; /* Teal 700 */
        }
        .input-focus:focus {
            border-color: #0d9488;
            box-shadow: 0 0 0 3px rgba(13, 148, 136, 0.4);
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-4">

    <!-- Login Container -->
    <div class="w-full max-w-sm bg-white p-8 rounded-xl shadow-2xl space-y-6 login-card">

        <!-- Header -->
        <header class="text-center">
            <i data-lucide="shield" class="h-10 w-10 text-teal-600 mx-auto mb-2"></i>
            <h2 class="text-3xl font-extrabold text-gray-900">
                Admin Access
            </h2>
            <p class="mt-1 text-sm text-gray-500">
                Hostel System Administration Panel
            </p>
        </header>

        <!-- Login Form -->
        <form method="post" class="space-y-4">

            <!-- Username Field -->
            <div>
                <label for="username" class="sr-only">Username</label>
                <input id="username" type="text" name="username" placeholder="Admin Username" required
                       class="w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 text-gray-900 input-focus focus:ring-transparent focus:outline-none"
                       autocomplete="off">
            </div>

            <!-- Password Field -->
            <div>
                <label for="password" class="sr-only">Password</label>
                <input id="password" type="password" name="password" placeholder="Password" required
                       class="w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 text-gray-900 input-focus focus:ring-transparent focus:outline-none">
            </div>

            <!-- Login Button -->
            <button type="submit" class="w-full text-white btn-primary py-3 rounded-lg font-semibold shadow-md hover:shadow-lg flex items-center justify-center space-x-2">
                <i data-lucide="log-in" class="h-5 w-5"></i>
                <span>Secure Sign In</span>
            </button>

        </form>

        <!-- Error Message -->
        <% if (!msg.isEmpty()) { %>
            <div class="p-3 text-sm text-red-700 bg-red-100 rounded-lg border border-red-400 text-center">
                <p class="font-medium"><%= msg %></p>
            </div>
        <% } %>

        <!-- Go Back Link -->
        <div class="pt-4 border-t border-gray-200 text-center">
            <a href="index_enhanced.html" class="text-sm font-medium text-gray-500 hover:text-teal-600 transition-colors">
                ← Return to Portal Selection
            </a>
        </div>
    </div>

    <!-- Re-initialize Lucide Icons -->
    <script>
        lucide.createIcons();
    </script>
</body>
</html>