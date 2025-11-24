<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // AUTHENTICATION CHECK: Assuming student is logged in and session attribute is set.
    // In a full MVC, the Servlet would set these details, but here we fetch them directly.
    Integer studentId = (Integer) session.getAttribute("student_id");
    String studentName = (String) session.getAttribute("student_name");
    String studentRollNo = (String) session.getAttribute("student_roll");

    if (studentId == null) {
        // Redirect to login if session isn't properly set for a student
        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
        return;
    }

    String pageTitle = "Your Room & Roommates";

    // Database credentials
    String DB_URL = "jdbc:mysql://localhost:3306/hostel_management_db?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "your_mysql_password"; // <-- UPDATE THIS

    // Room and Roommate data structures
    String roomNo = "N/A";
    String roomStatus = "N/A";
    int roomCapacity = 0;
    int roomOccupied = 0;
    int allocatedRoomId = 0;
    StringBuilder roommateListHtml = new StringBuilder();

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // 1. Get the current student's room_id
        ps = con.prepareStatement("SELECT room_id, roll_number, name FROM students WHERE student_id = ?");
        ps.setInt(1, studentId);
        rs = ps.executeQuery();

        if (rs.next()) {
            // Re-fetch necessary student data from DB, just in case
            studentRollNo = rs.getString("roll_number");
            studentName = rs.getString("name");

            allocatedRoomId = rs.getInt("room_id");
            if (allocatedRoomId == 0) {
                // Not allocated, handle below
            }
        }
        if (rs != null) rs.close();
        if (ps != null) ps.close();

        if (allocatedRoomId > 0) {
            // 2. Get Room Details (room_no, capacity, occupied)
            ps = con.prepareStatement("SELECT room_no, capacity, occupied, status FROM rooms WHERE room_id = ?");
            ps.setInt(1, allocatedRoomId);
            rs = ps.executeQuery();

            if (rs.next()) {
                roomNo = rs.getString("room_no");
                roomCapacity = rs.getInt("capacity");
                roomOccupied = rs.getInt("occupied");
                roomStatus = rs.getString("status");
            }
            if (rs != null) rs.close();
            if (ps != null) ps.close();

            // 3. Get Roommates (other students in the same room)
            ps = con.prepareStatement(
                "SELECT roll_number, name FROM students WHERE room_id = ? AND student_id != ? ORDER BY name"
            );
            ps.setInt(1, allocatedRoomId);
            ps.setInt(2, studentId);
            rs = ps.executeQuery();

            // Add current student first
            roommateListHtml.append("<li class='flex items-center space-x-3 p-3 bg-indigo-50 rounded-lg shadow-sm border-l-4 border-indigo-600'>");
            roommateListHtml.append("    <i data-lucide='user-check' class='h-6 w-6 text-teal-500'></i>");
            roommateListHtml.append("    <div>");
            roommateListHtml.append("        <p class='font-semibold'>").append(studentName).append(" (You)</p>");
            roommateListHtml.append("        <p class='text-sm text-gray-500'>Roll No: ").append(studentRollNo).append("</p>");
            roommateListHtml.append("    </div>");
            roommateListHtml.append("</li>");

            boolean hasRoommates = false;
            while (rs.next()) {
                hasRoommates = true;
                String rRollNo = rs.getString("roll_number");
                String rName = rs.getString("name");

                roommateListHtml.append("<li class='flex items-center space-x-3 p-3 bg-gray-100 rounded-lg shadow-sm border-l-4 border-gray-300'>");
                roommateListHtml.append("    <i data-lucide='user' class='h-6 w-6 text-indigo-500'></i>");
                roommateListHtml.append("    <div>");
                roommateListHtml.append("        <p class='font-semibold'>").append(rName).append("</p>");
                roommateListHtml.append("        <p class='text-sm text-gray-500'>Roll No: ").append(rRollNo).append("</p>");
                roommateListHtml.append("    </div>");
                roommateListHtml.append("</li>");
            }

            if (!hasRoommates && roomCapacity > 1) {
                roommateListHtml.append("<li class='p-3 text-gray-500 text-sm'>No other roommates currently assigned.</li>");
            }


        } else {
            // Not Allocated Path
            roomNo = "UNALLOCATED";
            roommateListHtml.append("<li class='p-3 text-gray-500 text-sm'>You have not been assigned a room yet.</li>");
        }

    } catch (Exception e) {
        roomNo = "ERROR";
        roommateListHtml.append("<li class='p-3 text-red-500 text-sm'>Error loading room data: ").append(e.getMessage()).append("</li>");
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
        if (con != null) try { con.close(); } catch (SQLException ignore) {}
    }
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
        :root { --color-primary: #4f46e5; --color-accent: #14b8a6; }
        body { font-family: 'Inter', sans-serif; background-color: #f9fafb; }
    </style>
</head>
<body class="h-screen flex overflow-hidden bg-gray-50">

    <%-- Placeholder Layout Structure --%>
    <div class="flex-1 flex flex-col">
        <header class="h-20 bg-white shadow-md flex items-center px-6 z-10"><h1 class="text-2xl font-semibold text-gray-800"><%= pageTitle %></h1></header>

        <main class="flex-1 p-4 sm:p-6 md:p-8 overflow-y-auto">
            <h2 class="text-3xl font-bold text-gray-800 mb-6">Room Allocation Details</h2>

            <div class="bg-white p-8 rounded-xl shadow-2xl transform hover:shadow-3xl transition duration-300">
                <% if (allocatedRoomId > 0) { %>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
                        <div>
                            <h3 class="text-xl font-bold text-indigo-600 mb-4 flex items-center space-x-2">
                                <i data-lucide="bed-single" class="w-5 h-5"></i>
                                <span>Your Room: <%= roomNo %></span>
                            </h3>
                            <div class="space-y-4 text-gray-700 p-4 border border-gray-200 rounded-xl bg-gray-50">
                                <div class="flex justify-between border-b pb-2"><span class="font-medium">Room Number:</span><span class="font-bold text-lg"><%= roomNo %></span></div>
                                <div class="flex justify-between border-b pb-2"><span class="font-medium">Capacity:</span><span><%= roomCapacity %></span></div>
                                <div class="flex justify-between border-b pb-2"><span class="font-medium">Occupancy:</span><span><%= roomOccupied %> / <%= roomCapacity %></span></div>
                                <div class="flex justify-between pb-2"><span class="font-medium">Status:</span>
                                    <span class="font-bold <%= "Available".equals(roomStatus) ? "text-green-600" : "text-yellow-600" %>">
                                        <%= roomStatus %>
                                    </span>
                                </div>
                            </div>
                            <p class="mt-4 text-sm text-gray-500">
                                This room is reserved for you until the next academic session ends.
                            </p>
                        </div>

                        <div>
                            <h3 class="text-xl font-semibold text-indigo-600 mb-4 flex items-center space-x-2">
                                <i data-lucide="users" class="w-5 h-5"></i>
                                <span>Roommates</span>
                            </h3>
                            <ul class="space-y-3">
                                <%= roommateListHtml.toString() %>
                            </ul>
                        </div>
                    </div>
                <% } else { %>
                    <div class="p-8 text-center bg-yellow-50 border-4 border-dashed border-yellow-300 rounded-xl">
                        <i data-lucide="alert-triangle" class="w-10 h-10 text-yellow-600 mx-auto mb-4"></i>
                        <h3 class="text-2xl font-bold text-yellow-800 mb-2">Room Not Allocated</h3>
                        <p class="text-gray-700">Your enrollment is active, but you have not been assigned a hostel room yet.</p>
                        <ul class="mt-4 text-sm text-gray-600">
                            <li><i data-lucide="mail" class="w-4 h-4 inline mr-2"></i> Contact the administration if you believe this is an error.</li>
                        </ul>
                    </div>
                <% } %>
            </div>

            <a href="<%= request.getContextPath() %>/StudentDashboardServlet" class="mt-8 text-indigo-600 hover:text-indigo-800 font-medium flex items-center justify-center space-x-2">
                <i data-lucide="arrow-left" class="h-4 w-4"></i>
                <span>Back to Dashboard</span>
            </a>
        </main>
    </div>
<script>
    lucide.createIcons();
    // Assuming toggleSidebar function is defined in a component file if using a full layout
</script>
</body>
</html>