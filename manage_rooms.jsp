<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // --- AUTHENTICATION CHECK ---
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("index.jsp");
        return;
    }

    String pageTitle = "Room Management Console";
    String message = "";
    String messageType = "";

    String DB_URL = "jdbc:mysql://localhost:3306/hostel_db?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "admin";

    Connection con = null;
    PreparedStatement ps = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // --- ADD ROOM LOGIC ---
        if (request.getParameter("add_room") != null) {
            String roomNo = request.getParameter("room_no");
            int capacity = Integer.parseInt(request.getParameter("capacity"));

            try {
                ps = con.prepareStatement("INSERT INTO rooms (room_no, capacity, status, occupied) VALUES (?, ?, 'Available', 0)");
                ps.setString(1, roomNo);
                ps.setInt(2, capacity);
                if (ps.executeUpdate() > 0) {
                    message = "Room " + roomNo + " added successfully.";
                    messageType = "success";
                }
            } catch (Exception e) {
                message = "Error adding room: " + e.getMessage();
                messageType = "error";
            }
        }

        // --- DELETE ROOM LOGIC ---
        if (request.getParameter("delete") != null) {
            int rid = Integer.parseInt(request.getParameter("delete"));
            try {
                ps = con.prepareStatement("DELETE FROM rooms WHERE room_id=?");
                ps.setInt(1, rid);
                if (ps.executeUpdate() > 0) {
                    message = "Room deleted successfully.";
                    messageType = "success";
                }
            } catch (Exception e) {
                message = "Error deleting room: " + e.getMessage();
                messageType = "error";
            }
        }

        // --- UPDATE ROOM LOGIC ---
        if (request.getParameter("update_room") != null) {
            int rid = Integer.parseInt(request.getParameter("rid"));
            String roomNo = request.getParameter("room_no");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            String status = request.getParameter("status");
            // Parsing the occupied flag as requested
            int occupiedVal = 0;
            try {
                occupiedVal = Integer.parseInt(request.getParameter("occupied_flag"));
            } catch(NumberFormatException e) { occupiedVal = 0; }

            try {
                ps = con.prepareStatement("UPDATE rooms SET room_no=?, capacity=?, status=?, occupied=? WHERE room_id=?");
                ps.setString(1, roomNo);
                ps.setInt(2, capacity);
                ps.setString(3, status);
                ps.setInt(4, occupiedVal);
                ps.setInt(5, rid);

                if (ps.executeUpdate() > 0) {
                    message = "Room " + roomNo + " updated successfully.";
                    messageType = "success";
                }
            } catch (Exception e) {
                message = "Error updating room: " + e.getMessage();
                messageType = "error";
            }
        }

    } catch (Exception e) {
        message = "Database Connection Error: " + e.getMessage();
        messageType = "error";
    }
    // Connection kept open for reading data below
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %></title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0f172a;
            /* Admin Command Center Background */
            background-image:
                linear-gradient(180deg, rgba(6, 182, 212, 0.05) 0%, rgba(15, 23, 42, 0) 30%),
                radial-gradient(circle at 100% 0%, rgba(16, 185, 129, 0.08) 0%, transparent 40%),
                radial-gradient(circle at 0% 0%, rgba(6, 182, 212, 0.08) 0%, transparent 40%);
            min-height: 100vh;
            color: #e2e8f0;
        }

        h1, h2, h3, h4 { font-family: 'Space Grotesk', sans-serif; }

        /* --- GLASS COMPONENTS --- */
        .glass-card {
            background: rgba(30, 41, 59, 0.6);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
        }

        /* --- TABLE STYLING --- */
        .table-header {
            background: rgba(15, 23, 42, 0.9);
            border-bottom: 1px solid rgba(6, 182, 212, 0.2);
        }
        .table-row {
            border-bottom: 1px solid rgba(255, 255, 255, 0.03);
            transition: all 0.2s;
        }
        .table-row:hover {
            background: rgba(6, 182, 212, 0.05);
        }

        /* --- STATUS BADGES --- */
        .status-Available { background: rgba(16, 185, 129, 0.1); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.2); }
        .status-Occupied { background: rgba(239, 68, 68, 0.1); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.2); }
        .status-Maintenance { background: rgba(245, 158, 11, 0.1); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.2); }

        /* --- INPUTS --- */
        .admin-input {
            background: rgba(15, 23, 42, 0.8);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: white;
            transition: all 0.2s;
        }
        .admin-input:focus {
            border-color: #06b6d4;
            outline: none;
            box-shadow: 0 0 0 2px rgba(6, 182, 212, 0.2);
        }

    </style>
</head>

<body class="p-4 sm:p-6 min-h-screen">

<div class="max-w-7xl mx-auto animate-fade-in-up">

    <!-- Header -->
    <div class="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">Room Manager</h2>
            <p class="text-slate-400 mt-1">Configure hostel capacity and allocation.</p>
        </div>

        <a href="hostel.jsp" class="group flex items-center gap-2 px-5 py-2.5 rounded-xl bg-slate-800/50 border border-slate-700 hover:border-cyan-500/50 transition-all text-sm font-medium text-slate-300 hover:text-white">
            <i data-lucide="layout-dashboard" class="h-4 w-4 group-hover:-translate-x-1 transition-transform"></i>
            Back to Dashboard
        </a>
    </div>

    <!-- Alert Messages -->
    <% if (!message.isEmpty()) { %>
        <div class="mb-6 p-4 rounded-xl flex items-center gap-3 border backdrop-blur-md shadow-lg
            <% if ("success".equals(messageType)) { %> bg-emerald-500/10 border-emerald-500/20 text-emerald-400
            <% } else { %> bg-red-500/10 border-red-500/20 text-red-400 <% } %>">
            <i data-lucide="<%= "success".equals(messageType) ? "check-circle" : "alert-triangle" %>" class="h-5 w-5"></i>
            <p class="font-medium text-sm"><%= message %></p>
        </div>
    <% } %>

    <!-- Grid Layout: Add Room (Left) & Room List (Right) -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

        <!-- ADD NEW ROOM CARD -->
        <div class="lg:col-span-1 h-fit">
            <div class="glass-card rounded-2xl p-6 border-t-4 border-t-cyan-500">
                <h3 class="text-xl font-bold text-white mb-4 flex items-center gap-2">
                    <i data-lucide="plus-circle" class="h-5 w-5 text-cyan-400"></i>
                    Add Room
                </h3>

                <form method="post" class="space-y-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Room Number</label>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <i data-lucide="door-closed" class="h-4 w-4 text-slate-500"></i>
                            </span>
                            <input type="text" name="room_no" required class="admin-input w-full rounded-lg pl-10 pr-4 py-2.5" placeholder="e.g. A-101">
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Capacity</label>
                        <div class="relative">
                            <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                <i data-lucide="users" class="h-4 w-4 text-slate-500"></i>
                            </span>
                            <input type="number" name="capacity" required class="admin-input w-full rounded-lg pl-10 pr-4 py-2.5" placeholder="e.g. 2">
                        </div>
                    </div>

                    <button type="submit" name="add_room" class="w-full mt-2 bg-cyan-600 hover:bg-cyan-500 text-white font-bold py-3 rounded-xl shadow-lg shadow-cyan-900/20 flex items-center justify-center gap-2 transition-all group">
                        <i data-lucide="save" class="h-4 w-4 group-hover:scale-110 transition-transform"></i>
                        <span>Save to Database</span>
                    </button>
                </form>
            </div>
        </div>

        <!-- ROOM LIST TABLE -->
        <div class="lg:col-span-2">
            <div class="glass-card rounded-2xl overflow-hidden border border-slate-700/50 flex flex-col h-full max-h-[800px]">
                <div class="p-4 border-b border-slate-700/50 bg-slate-900/50 flex justify-between items-center">
                    <h3 class="font-bold text-white flex items-center gap-2">
                        <i data-lucide="list" class="h-4 w-4 text-emerald-400"></i>
                        Room Directory
                    </h3>
                </div>

                <div class="overflow-y-auto flex-1">
                    <table class="w-full text-left border-collapse">
                        <thead class="table-header sticky top-0 z-10">
                            <tr>
                                <th class="px-6 py-3 text-xs font-bold text-cyan-300 uppercase tracking-wider">Room No</th>
                                <th class="px-6 py-3 text-xs font-bold text-cyan-300 uppercase tracking-wider">Capacity</th>
                                <th class="px-6 py-3 text-xs font-bold text-cyan-300 uppercase tracking-wider">Occupied</th>
                                <th class="px-6 py-3 text-xs font-bold text-cyan-300 uppercase tracking-wider">Status</th>
                                <th class="px-6 py-3 text-xs font-bold text-cyan-300 uppercase tracking-wider text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-white/5">
                            <%
                                if (con != null) {
                                    try {
                                        ps = con.prepareStatement("SELECT * FROM rooms ORDER BY room_no ASC");
                                        ResultSet rs = ps.executeQuery();
                                        while (rs.next()) {
                                            String status = rs.getString("status");
                            %>
                            <tr class="table-row group">
                                <td class="px-6 py-4">
                                    <span class="font-mono text-sm font-bold text-white"><%= rs.getString("room_no") %></span>
                                </td>
                                <td class="px-6 py-4 text-sm text-slate-300">
                                    <%= rs.getInt("capacity") %> Beds
                                </td>
                                <td class="px-6 py-4 text-sm text-slate-300">
                                    <%= rs.getInt("occupied") %> Students
                                </td>
                                <td class="px-6 py-4">
                                    <span class="px-2 py-1 rounded text-[10px] font-bold uppercase tracking-wide <%= "status-" + status %>">
                                        <%= status %>
                                    </span>
                                </td>
                                <td class="px-6 py-4 text-right">
                                    <div class="flex items-center justify-end gap-2">
                                        <a href="manage_rooms.jsp?edit=<%= rs.getInt("room_id") %>#editSection" class="p-2 rounded-lg bg-indigo-500/10 text-indigo-400 hover:bg-indigo-500 hover:text-white transition-colors" title="Edit">
                                            <i data-lucide="pen-line" class="h-4 w-4"></i>
                                        </a>
                                        <a href="manage_rooms.jsp?delete=<%= rs.getInt("room_id") %>" class="p-2 rounded-lg bg-red-500/10 text-red-400 hover:bg-red-500 hover:text-white transition-colors" title="Delete" onclick="return confirm('Delete this room?');">
                                            <i data-lucide="trash-2" class="h-4 w-4"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>
                            <%
                                        }
                                    } catch (Exception e) {
                                        out.println("<tr><td colspan='5' class='p-4 text-center text-red-400'>Error loading data: " + e.getMessage() + "</td></tr>");
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- EDIT SECTION (Conditional Render) -->
    <%
        if (request.getParameter("edit") != null && con != null) {
            int rid = Integer.parseInt(request.getParameter("edit"));
            try {
                ps = con.prepareStatement("SELECT * FROM rooms WHERE room_id=?");
                ps.setInt(1, rid);
                ResultSet rs = ps.executeQuery();
                if(rs.next()) {
                    int occupiedCount = rs.getInt("occupied");
                    String isOccupied = occupiedCount > 0 ? "1" : "0";
                    String currentStatus = rs.getString("status");
    %>

    <div id="editSection" class="mt-8 animate-fade-in-up">
        <div class="glass-card rounded-2xl p-8 border-2 border-yellow-500/50 shadow-2xl shadow-yellow-500/10 relative overflow-hidden">
            <!-- Glow Effect -->
            <div class="absolute top-0 right-0 w-64 h-64 bg-yellow-500/10 rounded-full blur-3xl -mr-16 -mt-16 pointer-events-none"></div>

            <div class="flex items-center gap-3 mb-6">
                <div class="p-3 bg-yellow-500/20 rounded-xl text-yellow-400">
                    <i data-lucide="edit-3" class="h-6 w-6"></i>
                </div>
                <div>
                    <h3 class="text-2xl font-bold text-white">Edit Room Configuration</h3>
                    <p class="text-slate-400 text-sm">Modifying Room ID: #<%= rid %></p>
                </div>
            </div>

            <form method="post" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <input type="hidden" name="rid" value="<%= rid %>">

                <div>
                    <label class="block text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Room No</label>
                    <input type="text" name="room_no" value="<%= rs.getString("room_no") %>" required class="admin-input w-full rounded-lg px-4 py-2.5">
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Capacity</label>
                    <input type="number" name="capacity" value="<%= rs.getInt("capacity") %>" required class="admin-input w-full rounded-lg px-4 py-2.5">
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Status</label>
                    <select name="status" id="statusSelect" onchange="autoToggleOccupied()" class="admin-input w-full rounded-lg px-4 py-2.5 [&>option]:bg-slate-800">
                        <option <%= currentStatus.equals("Available") ? "selected" : "" %>>Available</option>
                        <option <%= currentStatus.equals("Occupied") ? "selected" : "" %>>Occupied</option>
                        <option <%= currentStatus.equals("Maintenance") ? "selected" : "" %>>Maintenance</option>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Is Occupied?</label>
                    <select name="occupied_flag" id="occupiedSelect" class="admin-input w-full rounded-lg px-4 py-2.5 [&>option]:bg-slate-800">
                        <option value="0" <%= isOccupied.equals("0") ? "selected" : "" %>>No (0)</option>
                        <option value="1" <%= isOccupied.equals("1") ? "selected" : "" %>>Yes (1+)</option>
                    </select>
                </div>

                <div class="md:col-span-2 lg:col-span-4 flex justify-end gap-3 pt-4 border-t border-white/5 mt-2">
                    <a href="manage_rooms.jsp" class="px-6 py-2.5 rounded-xl border border-slate-600 text-slate-300 hover:bg-slate-800 transition-colors font-medium">Cancel</a>
                    <button type="submit" name="update_room" class="px-6 py-2.5 rounded-xl bg-yellow-500 hover:bg-yellow-400 text-slate-900 font-bold shadow-lg shadow-yellow-500/20 transition-all">
                        Update Configuration
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Auto scroll to edit section
        document.getElementById('editSection').scrollIntoView({ behavior: 'smooth' });

        // Logic sync
        function autoToggleOccupied() {
            var status = document.getElementById("statusSelect").value;
            var occupiedSelect = document.getElementById("occupiedSelect");

            if (status === "Occupied") {
                occupiedSelect.value = "1";
            } else if (status === "Available") {
                occupiedSelect.value = "0";
            }
        }
    </script>
    <%
                }
            } catch (Exception e) {
                 out.println("<div class='mt-4 p-4 rounded-xl bg-red-500/20 text-red-400'>Error retrieving room data: " + e + "</div>");
            }
        }
    %>

</div>

<script>
    lucide.createIcons();
</script>
</body>
</html>
