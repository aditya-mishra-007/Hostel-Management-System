<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // --- AUTHENTICATION CHECK ---
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    // --- LOGIC FOR SUMMARY BOX (TOTAL, PAID, UNPAID) ---
    int total = 0;
    int paid = 0;
    int unpaid = 0;

    // Database credentials (Adjust as needed)
    String DB_URL = "jdbc:mysql://localhost:3306/hostel_db?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "admin";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // QUERY 1: Get fee status counts for summary
        ps = con.prepareStatement("SELECT fee_status FROM students");
        rs = ps.executeQuery();

        while (rs.next()) {
            total++;
            if ("Paid".equalsIgnoreCase(rs.getString("fee_status"))) paid++;
            else unpaid++;
        }

        if (rs != null) rs.close();
        if (ps != null) ps.close();

    } catch (Exception e) {
        // Log error, but continue to show the page
        out.println("<p class='text-red-600 text-center text-sm p-3 bg-red-100 rounded-lg'>Error fetching summary data: " + e.getMessage() + "</p>");
    } finally {
        // Connection needs to stay open for the next query block if it was successful
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fee Reports</title>
    <!-- Load Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Load Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        :root { --color-accent: #14b8a6; } /* Teal for Admin */
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f3f4f6;
        }
        .container-box {
            max-width: 1000px;
            margin: 40px auto;
            padding: 24px;
        }
        .data-row:hover {
            background-color: #f0fdfa; /* Light Teal background on hover */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
            transform: scale(1.005);
            transition: all 0.2s ease-in-out;
        }
        .unpaid-row {
            background-color: #fee2e2; /* Light Red */
            border-left: 4px solid #ef4444; /* Red border */
        }
    </style>
</head>
<body class="min-h-screen">

<div class="container-box">
    <h2 class="text-4xl font-extrabold text-gray-800 text-center mb-8">Hostel Fee Reports</h2>

    <!-- ---------- SUMMARY BOX (Widgets) ---------- -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">

        <!-- Widget 1: Total Students -->
        <div class="bg-white p-6 rounded-xl shadow-lg border-t-4 border-indigo-500">
            <div class="flex items-center justify-between">
                <p class="text-sm font-medium text-gray-500">Total Students</p>
                <i data-lucide="users" class="h-6 w-6 text-indigo-500"></i>
            </div>
            <p class="text-3xl font-extrabold text-indigo-700 mt-1"><%= total %></p>
        </div>

        <!-- Widget 2: Paid Students -->
        <div class="bg-white p-6 rounded-xl shadow-lg border-t-4 border-green-500">
            <div class="flex items-center justify-between">
                <p class="text-sm font-medium text-gray-500">Fee Paid</p>
                <i data-lucide="check-circle" class="h-6 w-6 text-green-500"></i>
            </div>
            <p class="text-3xl font-extrabold text-green-700 mt-1"><%= paid %></p>
        </div>

        <!-- Widget 3: Unpaid Students -->
        <div class="bg-white p-6 rounded-xl shadow-lg border-t-4 border-red-500">
            <div class="flex items-center justify-between">
                <p class="text-sm font-medium text-gray-500">Fee Unpaid / Pending</p>
                <i data-lucide="alert-triangle" class="h-6 w-6 text-red-500"></i>
            </div>
            <p class="text-3xl font-extrabold text-red-700 mt-1"><%= unpaid %></p>
        </div>
    </div>

    <!-- ---------- FEE DETAILS TABLE ---------- -->
    <div class="bg-white rounded-xl shadow-2xl overflow-hidden p-6">
        <h3 class="text-xl font-semibold text-teal-700 mb-4 flex items-center space-x-2">
             <i data-lucide="wallet" class="h-5 w-5"></i>
             <span>Detailed Fee Status</span>
        </h3>

        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-teal-500">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider rounded-tl-xl">Roll No</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider">Name</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider">Room No</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider rounded-tr-xl">Fee Status</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-100">

                <%
                    // QUERY 2: Get detailed student list
                    try {
                        // Re-use connection or create a new one if the first query closed it (original scriptlet doesn't close)
                        if (con == null || con.isClosed()) {
                            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                        }

                        ps = con.prepareStatement("SELECT roll_no, name, room_no, fee_status FROM students ORDER BY name ASC");
                        rs = ps.executeQuery();
                        boolean foundDetails = false;

                        while (rs.next()) {
                            foundDetails = true;
                            String rollNo = rs.getString("roll_no");
                            String name = rs.getString("name");
                            String roomNo = rs.getString("room_no");
                            String status = rs.getString("fee_status");

                            boolean isUnpaid = "Unpaid".equalsIgnoreCase(status);

                            String rowClass = isUnpaid ? "unpaid-row data-row" : "data-row";
                            String statusClass = isUnpaid ? "text-red-700 font-bold" : "text-green-700 font-semibold";
                %>

                    <tr class="<%= rowClass %>">
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= rollNo %></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= name %></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= roomNo != null ? roomNo : "N/A" %></td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm <%= statusClass %>"><%= status != null ? status : "N/A" %></td>
                    </tr>

                <%
                        }

                        if (!foundDetails) {
                            out.println("<tr><td colspan='4' class='p-6 text-center text-gray-500'>No student details found.</td></tr>");
                        }

                    } catch (Exception e) {
                        out.println("<tr><td colspan='4' class='p-6 text-center text-red-500'>Error retrieving details: " + e.getMessage() + "</td></tr>");
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
                        if (con != null) try { con.close(); } catch (SQLException ignore) {}
                    }
                %>

                </tbody>
            </table>
        </div>
    </div>

    <a href="hostel.jsp" class="text-indigo-600 hover:text-indigo-800 font-medium flex items-center justify-center space-x-2 mt-8">
        <i data-lucide="arrow-left" class="h-4 w-4"></i>
        <span>Back to Dashboard</span>
    </a>

</div>

<script>
    lucide.createIcons();
</script>

</body>
</html>