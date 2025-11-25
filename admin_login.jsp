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
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        /* PREMIUM DARK MODE STYLES */
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0f172a; /* Deep Slate Background */
        }
        .login-card {
            background-color: #1e293b; /* Dark Card Surface */
            border: 1px solid #334155; /* Subtle border */
            border-radius: 1.5rem;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5); /* Deep Shadow */
            transition: all 0.3s ease-in-out;
        }
        .input-field {
            background-color: #0f172a; /* Input background slightly darker than card */
            border: 1px solid #475569;
            color: #f1f5f9; /* Light text */
            transition: all 0.2s;
            border-radius: 0.5rem;
        }
        .input-field:focus {
            border-color: #3b82f6; /* Blue Focus */
            box-shadow: 0 0 0 2px #3b82f6, 0 0 10px rgba(59, 130, 246, 0.4);
            background-color: #1e293b;
        }
        .btn-primary {
            background-color: #3b82f6; /* Blue Primary Action */
            box-shadow: 0 4px 10px rgba(59, 130, 246, 0.4);
            font-weight: 700;
        }
        .btn-primary:hover {
            background-color: #2563eb;
            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.6);
            transform: translateY(-1px);
        }
        .error-msg {
            background-color: #ef4444;
            color: white;
            border-left: 4px solid #b91c1c;
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center p-4">

    <div class="w-full max-w-sm p-10 space-y-7 login-card">

        <header class="text-center">
            <i data-lucide="lock-keyhole" class="h-10 w-10 text-blue-400 mx-auto mb-2"></i>
            <h2 class="text-3xl font-extrabold text-white tracking-wider">
                ADMIN ACCESS
            </h2>
            <p class="mt-1 text-sm text-gray-400">
                Securely sign in to the Hostel Management Panel
            </p>
        </header>

        <form method="post" class="space-y-5">

            <div>
                <label for="username" class="sr-only">Username</label>
                <input id="username" type="text" name="username" placeholder="Username / Admin ID" required
                       class="w-full px-4 py-3 input-field focus:outline-none"
                       autocomplete="off">
            </div>

            <div>
                <label for="password" class="sr-only">Password</label>
                <input id="password" type="password" name="password" placeholder="Password" required
                       class="w-full px-4 py-3 input-field focus:outline-none">
            </div>

            <button type="submit" class="w-full text-white btn-primary py-3 rounded-xl font-bold uppercase tracking-wider flex items-center justify-center space-x-2">
                <i data-lucide="log-in" class="h-5 w-5"></i>
                <span>Sign In</span>
            </button>

        </form>

        <% if (!msg.isEmpty()) { %>
            <div class="p-3 text-sm error-msg rounded-lg border border-red-600 text-center">
                <p class="font-medium"><%= msg %></p>
            </div>
        <% } %>

        <div class="pt-6 border-t border-gray-700 text-center">
            <a href="index.jsp" class="text-sm font-medium text-gray-400 hover:text-blue-400 transition-colors flex items-center justify-center space-x-1">
                <i data-lucide="arrow-left" class="h-4 w-4"></i>
                <span>Return to Main Portal</span>
            </a>
        </div>
    </div>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
