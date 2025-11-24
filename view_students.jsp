<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // --- AUTHENTICATION CHECK ---
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String pageTitle = "Mark Daily Attendance";
    String message = "";
    String messageType = "success";

    // Database credentials (Adjust as needed)
    String DB_URL = "jdbc:mysql://localhost:3306/hostel_db?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "admin"; // <-- Using 'admin' as per your provided snippet

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // --- Handle Attendance Marking ---
        if (request.getParameter("action") != null) {
            String roll = request.getParameter("roll_no");
            String status = request.getParameter("action");

            // NOTE: The original code inserts attendance without a date.
            // In a real app, you MUST include a date column in the attendance table.

            // Assuming the 'attendance' table accepts roll_no and status
            ps = con.prepareStatement(
                "INSERT INTO attendance (roll_no, status, attendance_date) VALUES (?, ?, CURRENT_DATE())"
            );
            ps.setString(1, roll);
            ps.setString(2, status);
            // ps.setDate(3, java.sql.Date.valueOf(new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()))); // If attendance table has date

            if (ps.executeUpdate() > 0) {
                message = "Attendance marked as " + status + " for Roll " + roll + ".";
                messageType = "success";
            } else {
                message = "Failed to mark attendance.";
                messageType = "error";
            }
            if (ps != null) ps.close();
        }

    } catch (Exception e) {
        message = "Database Error: " + e.getMessage();
        messageType = "error";
    } finally {
        // Connection remains open for fetching data below
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %></title>
    <!-- Load Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Load Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        /* Custom Styles for Professional Look */
        :root {
            --color-primary: #4f46e5; /* Indigo */
            --color-accent: #14b8a6; /* Teal */
        }
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f3f4f6; /* Light Gray Background */
        }
        .container-box {
            max-width: 900px;
            margin: 40px auto;
            padding: 24px;
        }
        /* Style for table rows with hover effect */
        .data-row:hover {
            background-color: #f0fdfa; /* Light Teal background on hover */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.05);
            transform: scale(1.005);
            transition: all 0.2s ease-in-out;
        }
    </style>
</head>
<body class="min-h-screen">

<div class="container-box">
    <h2 class="text-4xl font-extrabold text-gray-800 text-center mb-6"><%= pageTitle %></h2>

    <%-- Message Display --%>
    <% if (!message.isEmpty()) { %>
        <div class="mb-6 p-4 rounded-lg text-sm shadow-md
            <% if ("success".equals(messageType)) { %>
                bg-green-100 border-l-4 border-green-500 text-green-700
            <% } else { %>
                bg-red-100 border-l-4 border-red-500 text-red-700
            <% } %>
            " role="alert">
            <p><%= message %></p>
        </div>
    <% } %>

    <div class="bg-white rounded-xl shadow-2xl overflow-hidden p-6">
        <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200 rounded-lg">
                <thead class="bg-teal-600">
                    <tr>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider rounded-tl-xl">Roll No</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider">Name</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider">Room No</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider">Fee Status</th>
                        <th class="px-6 py-3 text-center text-xs font-bold text-white uppercase tracking-wider rounded-tr-xl">Mark Attendance</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-100">

                <%
                    // --- Fetch Student List ---
                    boolean fetchSuccess = false;
                    try {
                        if (con == null || con.isClosed()) {
                            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                        }

                        // Query selects data based on your specific student table columns: roll_no, name, room_no, fee_status
                        ps = con.prepareStatement("SELECT roll_no, name, room_no, fee_status FROM students ORDER BY roll_no");
                        rs = ps.executeQuery();
                        boolean foundStudents = false;

                        while (rs.next()) {
                            foundStudents = true;
                            String rollNo = rs.getString("roll_no");
                            String name = rs.getString("name");
                            String roomNo = rs.getString("room_no");
                            String feeStatus = rs.getString("fee_status");

                            String feeClass = "text-gray-600";
                            if (feeStatus != null) {
                                if (feeStatus.equalsIgnoreCase("Paid")) {
                                    feeClass = "text-green-600 font-semibold";
                                } else if (feeStatus.equalsIgnoreCase("Unpaid")) {
                                    feeClass = "text-red-600 font-semibold";
                                }
                            }
                %>

                <tr class="data-row">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= rollNo %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= name %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= roomNo != null ? roomNo : "N/A" %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm <%= feeClass %>"><%= feeStatus != null ? feeStatus : "N/A" %></td>

                    <td class="px-6 py-4 whitespace-nowrap text-center space-x-3">

                        <%-- Present Form --%>
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="roll_no" value="<%= rollNo %>">
                            <button name="action" value="Present" class="py-2 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-green-500 hover:bg-green-600 shadow-md transition-colors">
                                Present
                            </button>
                        </form>

                        <%-- Absent Form --%>
                        <form method="post" style="display:inline;">
                            <input type="hidden" name="roll_no" value="<%= rollNo %>">
                            <button name="action" value="Absent" class="py-2 px-4 border border-transparent text-sm font-medium rounded-lg text-white bg-red-500 hover:bg-red-600 shadow-md transition-colors">
                                Absent
                            </button>
                        </form>
                    </td>
                </tr>

                <%
                        }

                        if (!foundStudents) {
                            out.print("<tr><td colspan='5' class='p-6 text-center text-gray-500'>No students found in the database.</td></tr>");
                        }

                        fetchSuccess = true;
                    } catch (Exception e) {
                        if (!fetchSuccess) {
                            out.print("<tr><td colspan='5' class='p-6 text-center text-red-500'>Error loading data: " + e.getMessage() + "</td></tr>");
                        }
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