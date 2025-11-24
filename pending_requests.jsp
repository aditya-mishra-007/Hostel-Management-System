<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // --- AUTHENTICATION CHECK ---
    if (session.getAttribute("admin") == null) {
        // Redirect to the login page defined in your index.jsp or base path
        response.sendRedirect("index.jsp");
        return;
    }

    String pageTitle = "Leave Requests Approval";
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

        // --- HANDLE APPROVE / REJECT LOGIC ---
        String action = request.getParameter("action");
        String id = request.getParameter("id");

        if (action != null && id != null) {
            String newStatus = "";
            String updateMessage = "";

            if (action.equals("approve")) {
                newStatus = "Approved";
                updateMessage = "Leave request ID " + id + " approved.";
            } else if (action.equals("reject")) {
                newStatus = "Rejected";
                updateMessage = "Leave request ID " + id + " rejected.";
            }

            if (!newStatus.isEmpty()) {
                ps = con.prepareStatement(
                    "UPDATE leave_requests SET status=? WHERE id=?"
                );
                ps.setString(1, newStatus);
                ps.setString(2, id);

                if (ps.executeUpdate() > 0) {
                    message = updateMessage;
                    messageType = "success";
                } else {
                    message = "Could not find pending request ID " + id + ".";
                    messageType = "error";
                }
                if (ps != null) ps.close();
            }
        }

    } catch (Exception e) {
        message = "Database Error: " + e.getMessage();
        messageType = "error";
        e.printStackTrace();
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
        :root { --color-accent: #14b8a6; }
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f3f4f6;
        }
        .container-box {
            max-width: 1200px;
            margin: 40px auto;
            padding: 24px;
        }
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
    <h2 class="text-4xl font-extrabold text-gray-800 text-center mb-8"><%= pageTitle %></h2>

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
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider rounded-tl-xl">ID</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider">Roll No</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider">Name</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider">Reason</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider">From Date</th>
                        <th class="px-6 py-3 text-left text-xs font-bold text-white uppercase tracking-wider">To Date</th>
                        <th class="px-6 py-3 text-center text-xs font-bold text-white uppercase tracking-wider">Status</th>
                        <th class="px-6 py-3 text-center text-xs font-bold text-white uppercase tracking-wider rounded-tr-xl">Action</th>
                    </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-100">

                <%
                    // --- SHOW ALL REQUESTS ---
                    boolean fetchSuccess = false;
                    try {
                        if (con == null || con.isClosed()) {
                            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                        }

                        // Select all requests
                        ps = con.prepareStatement(
                            "SELECT id, roll_no, name, reason, from_date, to_date, status FROM leave_requests ORDER BY id DESC"
                        );
                        rs = ps.executeQuery();
                        boolean foundRequests = false;

                        while (rs.next()) {
                            foundRequests = true;
                            int reqId = rs.getInt("id");
                            String rollNo = rs.getString("roll_no");
                            String name = rs.getString("name");
                            String reason = rs.getString("reason");
                            String fromDate = rs.getString("from_date");
                            String toDate = rs.getString("to_date");
                            String status = rs.getString("status");

                            String statusClass = "text-yellow-700 bg-yellow-100";
                            if ("Approved".equals(status)) {
                                statusClass = "text-green-700 bg-green-100";
                            } else if ("Rejected".equals(status)) {
                                statusClass = "text-red-700 bg-red-100";
                            }
                %>

                <tr class="data-row">
                    <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= reqId %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= rollNo %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= name %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500 max-w-xs truncate"><%= reason %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= fromDate %></td>
                    <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500"><%= toDate %></td>

                    <td class="px-6 py-4 whitespace-nowrap text-center">
                        <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full <%= statusClass %>">
                            <%= status %>
                        </span>
                    </td>

                    <td class="px-6 py-4 whitespace-nowrap text-center space-x-2">
                        <% if ("Pending".equals(status)) { %>

                            <a class="py-2 px-3 text-xs font-medium rounded-lg text-white bg-green-500 hover:bg-green-600 shadow-md transition-colors"
                               href="leave_requests_approval_enhanced.jsp?action=approve&id=<%= reqId %>">
                                <i data-lucide="check" class="h-4 w-4 inline mr-1"></i> Approve
                            </a>

                            <a class="py-2 px-3 text-xs font-medium rounded-lg text-white bg-red-500 hover:bg-red-600 shadow-md transition-colors"
                               href="leave_requests_approval_enhanced.jsp?action=reject&id=<%= reqId %>">
                                <i data-lucide="x" class="h-4 w-4 inline mr-1"></i> Reject
                            </a>

                        <% } else { %>
                            <span class="text-gray-400 font-medium">Completed</span>
                        <% } %>
                    </td>
                </tr>

                <%
                        }

                        if (!foundRequests) {
                            out.print("<tr><td colspan='8' class='p-6 text-center text-gray-500'>No pending or completed leave requests found.</td></tr>");
                        }

                        fetchSuccess = true;
                    } catch (Exception e) {
                        if (!fetchSuccess) {
                            out.print("<tr><td colspan='8' class='p-6 text-center text-red-500'>Error loading data: " + e.getMessage() + "</td></tr>");
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