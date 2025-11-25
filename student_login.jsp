<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // --- AUTHENTICATION & DATA RETRIEVAL ---
    if (session.getAttribute("student") == null) {
        response.sendRedirect("login.jsp"); // Redirect back to login if session is dead
        return;
    }

    String rollNo = (String) session.getAttribute("student_roll");
    String studentName = (String) session.getAttribute("student");
    String currentRoomNo = (String) session.getAttribute("student_room");

    String pageTitle = "My Room Allocation";

    String url = "jdbc:mysql://localhost:3306/hostel_db";
    String dbUser = "root";
    String dbPass = "admin";

    Connection conn = null;
    PreparedStatement pst = null;
    ResultSet rs = null;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %></title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <style>
        body { font-family: 'Inter', sans-serif; background-color: #f3f4f6; }
        .container-box { max-width: 900px; margin: 40px auto; padding: 24px; }
        .data-card { border-radius: 1rem; box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05); }
        .data-row:hover { background-color: #eef2f3; }
    </style>
</head>
<body class="min-h-screen">

<div class="container-box">
    <h2 class="text-4xl font-extrabold text-gray-800 text-center mb-2"><%= pageTitle %></h2>
    <h3 class="text-xl font-medium text-indigo-600 text-center mb-8">Welcome, <%= studentName %>!</h3>

    <div class="bg-white data-card overflow-hidden shadow-2xl p-8 border border-gray-100">

        <h3 class="text-2xl font-bold text-gray-700 mb-4 flex items-center space-x-2 border-b pb-3">
            <i data-lucide="bed" class="h-6 w-6 text-indigo-600"></i>
            <span>My Current Room Status</span>
        </h3>

        <%
            if (currentRoomNo == null || currentRoomNo.trim().isEmpty() || "null".equalsIgnoreCase(currentRoomNo)) {
        %>
            <%-- ROOM NOT ALLOCATED DISPLAY --%>
            <div class="text-center py-10">
                <i data-lucide="x-circle" class="h-12 w-12 text-red-500 mx-auto mb-4"></i>
                <p class="text-xl font-semibold text-gray-700">Room Not Yet Assigned.</p>
                <p class="text-gray-500 mt-2">Please contact the hostel administration for your room number allocation.</p>
            </div>
        <%
            } else {
        %>
            <%-- ROOM ALLOCATED DISPLAY --%>
            <div class="grid grid-cols-2 gap-4 mb-8">
                <div>
                    <p class="text-sm font-medium text-gray-500">Your Roll No</p>
                    <p class="text-2xl font-bold text-gray-800"><%= rollNo %></p>
                </div>
                <div>
                    <p class="text-sm font-medium text-gray-500">Assigned Room</p>
                    <p class="text-2xl font-bold text-green-600 flex items-center space-x-2">
                        <i data-lucide="home" class="h-6 w-6"></i>
                        <span><%= currentRoomNo %></span>
                    </p>
                </div>
            </div>

            <h3 class="text-2xl font-bold text-gray-700 mb-4 flex items-center space-x-2 border-b pb-3 pt-4">
                <i data-lucide="users" class="h-6 w-6 text-indigo-600"></i>
                <span>My Roommates</span>
            </h3>

            <%-- ROOMMATES TABLE FETCH --%>
            <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-100">
                        <tr>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">Name</th>
                            <th class="px-6 py-3 text-left text-xs font-bold text-gray-600 uppercase tracking-wider">Email</th>
                            <th class="px-6 py-3 text-center text-xs font-bold text-gray-600 uppercase tracking-wider">Status</th>
                        </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-100">
                        <%
                            boolean hasRoommates = false;
                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection(url, dbUser, dbPass);

                                String roommatesQuery = "SELECT name, email, roll_no FROM students WHERE room_no=? AND roll_no<>?";
                                pst = conn.prepareStatement(roommatesQuery);
                                pst.setString(1, currentRoomNo);
                                pst.setString(2, rollNo);
                                rs = pst.executeQuery();

                                while(rs.next()) {
                                    hasRoommates = true;
                        %>
                        <tr class="data-row">
                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900"><%= rs.getString("name") %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-700"><%= rs.getString("email") %></td>
                            <td class="px-6 py-4 whitespace-nowrap text-center text-sm text-green-500 font-medium">Assigned</td>
                        </tr>
                        <%
                                }
                                if(!hasRoommates) {
                        %>
                        <tr>
                            <td colspan="3" class="px-6 py-4 text-center text-gray-500 italic">No roommates found in this room. You have the room to yourself.</td>
                        </tr>
                        <%
                                }
                            } catch(Exception e) {
                        %>
                        <tr>
                            <td colspan="3" class="px-6 py-4 text-center text-red-500">Database Error: <%= e.getMessage() %></td>
                        </tr>
                        <%
                            } finally {
                                try { if(rs != null) rs.close(); } catch(Exception e) {}
                                try { if(pst != null) pst.close(); } catch(Exception e) {}
                                try { if(conn != null) conn.close(); } catch(Exception e) {}
                            }
                        %>
                    </tbody>
                </table>
            </div>
        <%
            }
        %>
    </div>

    <div class="text-center mt-8">
        <a href="hostel.jsp" class="py-3 px-8 text-base font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 shadow-xl transition-all transform hover:scale-105 inline-flex items-center space-x-2">
            <i data-lucide="layout-dashboard" class="h-5 w-5"></i>
            <span>Go to Main Dashboard</span>
        </a>
    </div>

</div>

<script>
    lucide.createIcons();
</script>
</body>
</html>
