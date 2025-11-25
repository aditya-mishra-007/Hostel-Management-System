<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // --- AUTHENTICATION CHECK ---
    if (session.getAttribute("admin") == null) {
        response.sendRedirect("index.jsp"); // Ensure this redirects to your main login page
        return;
    }

    String pageTitle = "Student Directory & Attendance";
    String message = "";
    String messageType = "success";

    // Database credentials
    String DB_URL = "jdbc:mysql://localhost:3306/hostel_db?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "admin";

    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

        // --- 1. Handle Attendance Marking ---
        if ("Present".equals(request.getParameter("action")) || "Absent".equals(request.getParameter("action"))) {
            String roll = request.getParameter("roll_no");
            String status = request.getParameter("action");

            // Check existing attendance
            PreparedStatement checkPs = con.prepareStatement(
                "SELECT COUNT(*) FROM attendance WHERE roll_no = ? AND attendance_date = CURRENT_DATE()"
            );
            checkPs.setString(1, roll);
            ResultSet checkRs = checkPs.executeQuery();

            if (checkRs.next() && checkRs.getInt(1) > 0) {
                 message = "Attendance for " + roll + " is already marked for today.";
                 messageType = "error";
            } else {
                ps = con.prepareStatement(
                    "INSERT INTO attendance (roll_no, status, attendance_date) VALUES (?, ?, CURRENT_DATE())"
                );
                ps.setString(1, roll);
                ps.setString(2, status);

                if (ps.executeUpdate() > 0) {
                    message = "Marked **" + roll + "** as " + status + ".";
                    messageType = "success";
                } else {
                    message = "Failed to mark attendance.";
                    messageType = "error";
                }
            }
            if (ps != null) ps.close();
        }

        // --- 2. Handle Adding New Student ---
        if ("add_student".equals(request.getParameter("action_type"))) {
            String roll = request.getParameter("new_roll_no");
            String name = request.getParameter("new_name");
            String room = request.getParameter("new_room_no");
            String fee = request.getParameter("new_fee_status");

            PreparedStatement checkPs = con.prepareStatement("SELECT COUNT(*) FROM students WHERE roll_no = ?");
            checkPs.setString(1, roll);
            ResultSet checkRs = checkPs.executeQuery();

            if (checkRs.next() && checkRs.getInt(1) > 0) {
                message = "Roll No **" + roll + "** already exists.";
                messageType = "error";
            } else {
                ps = con.prepareStatement(
                    "INSERT INTO students (roll_no, name, room_no, fee_status) VALUES (?, ?, ?, ?)"
                );
                ps.setString(1, roll);
                ps.setString(2, name);
                ps.setString(3, room);
                ps.setString(4, fee);

                if (ps.executeUpdate() > 0) {
                    message = "Added student **" + name + "** successfully.";
                    messageType = "success";
                } else {
                    message = "Failed to add student.";
                    messageType = "error";
                }
            }
            if (ps != null) ps.close();
        }

    } catch (Exception e) {
        message = "System Error: " + e.getMessage();
        messageType = "error";
        if (con != null) try { con.close(); } catch (SQLException ignore) {}
        con = null;
    }
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
            background-color: #0f172a; /* Slate 900 - More distinct professional dark */
            /* Admin "Command Center" Background */
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
            background: rgba(30, 41, 59, 0.6); /* Slightly lighter/bluer glass for admin */
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
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
            background: rgba(6, 182, 212, 0.05); /* Subtle Cyan Tint on Hover */
        }

        /* --- BUTTONS --- */
        .btn-action {
            transition: all 0.2s;
        }
        .btn-action:hover { transform: scale(1.05); }

        /* --- STATUS BADGES --- */
        .status-Paid { background: rgba(16, 185, 129, 0.1); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.2); }
        .status-Unpaid { background: rgba(239, 68, 68, 0.1); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.2); }
        .status-Partial { background: rgba(245, 158, 11, 0.1); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.2); }

    </style>
</head>

<body class="p-4 sm:p-6 min-h-screen">

<div class="max-w-6xl mx-auto animate-fade-in-up">

    <!-- Header & Actions -->
    <div class="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">Student Directory</h2>
            <div class="flex items-center gap-2 mt-2">
                <span class="px-3 py-1 rounded-full bg-cyan-500/10 border border-cyan-500/20 text-cyan-400 text-xs font-bold uppercase tracking-wider">
                    Today: <%= new java.text.SimpleDateFormat("dd MMM, yyyy").format(new java.util.Date()) %>
                </span>
            </div>
        </div>

        <button onclick="document.getElementById('addStudentModal').classList.remove('hidden')"
            class="group bg-cyan-600 hover:bg-cyan-500 text-white font-bold py-3 px-6 rounded-xl shadow-lg shadow-cyan-900/20 flex items-center gap-2 transition-all">
            <i data-lucide="user-plus" class="h-5 w-5 group-hover:scale-110 transition-transform"></i>
            <span>Add New Student</span>
        </button>
    </div>

    <!-- Message Alert -->
    <% if (!message.isEmpty()) { %>
        <div class="mb-6 p-4 rounded-xl flex items-center gap-3 border backdrop-blur-md shadow-lg animate-bounce-short
            <% if ("success".equals(messageType)) { %> bg-emerald-500/10 border-emerald-500/20 text-emerald-400
            <% } else { %> bg-red-500/10 border-red-500/20 text-red-400 <% } %>">
            <i data-lucide="<%= "success".equals(messageType) ? "check-circle" : "alert-triangle" %>" class="h-5 w-5"></i>
            <p class="font-medium text-sm"><%= message %></p>
        </div>
    <% } %>

    <!-- Main Data Table -->
    <div class="glass-card rounded-2xl overflow-hidden border border-slate-700/50">
        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead class="table-header">
                    <tr>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">Roll No</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">Name</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">Room</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">Fee Status</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider text-center">Mark Attendance</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-white/5">

                <%
                    if (con != null) {
                        try {
                            ps = con.prepareStatement("SELECT roll_no, name, room_no, fee_status FROM students ORDER BY roll_no");
                            rs = ps.executeQuery();
                            boolean foundStudents = false;

                            while (rs.next()) {
                                foundStudents = true;
                                String rollNo = rs.getString("roll_no");
                                String name = rs.getString("name");
                                String roomNo = rs.getString("room_no");
                                String feeStatus = rs.getString("fee_status");
                %>
                <tr class="table-row group">
                    <td class="px-6 py-4">
                        <span class="font-mono text-sm font-bold text-white bg-slate-800/50 border border-slate-700 px-2 py-1 rounded"><%= rollNo %></span>
                    </td>
                    <td class="px-6 py-4">
                        <div class="flex items-center gap-3">
                            <div class="h-8 w-8 rounded-full bg-cyan-500/20 flex items-center justify-center text-cyan-300 text-xs font-bold border border-cyan-500/30">
                                <%= name.substring(0, 1) %>
                            </div>
                            <span class="text-sm font-medium text-slate-200 group-hover:text-white transition-colors"><%= name %></span>
                        </div>
                    </td>
                    <td class="px-6 py-4 text-sm text-slate-400"><%= roomNo != null ? roomNo : "-" %></td>
                    <td class="px-6 py-4">
                        <span class="px-2 py-1 rounded text-[10px] font-bold uppercase tracking-wide <%= "status-" + (feeStatus != null ? feeStatus : "Unpaid") %>">
                            <%= feeStatus != null ? feeStatus : "N/A" %>
                        </span>
                    </td>
                    <td class="px-6 py-4 text-center">
                        <div class="flex items-center justify-center gap-2">
                            <form method="post">
                                <input type="hidden" name="roll_no" value="<%= rollNo %>">
                                <button name="action" value="Present" title="Mark Present" class="btn-action h-8 w-8 rounded-lg bg-emerald-500/20 text-emerald-400 border border-emerald-500/30 flex items-center justify-center hover:bg-emerald-500 hover:text-white">
                                    <i data-lucide="check" class="h-4 w-4"></i>
                                </button>
                            </form>
                            <form method="post">
                                <input type="hidden" name="roll_no" value="<%= rollNo %>">
                                <button name="action" value="Absent" title="Mark Absent" class="btn-action h-8 w-8 rounded-lg bg-red-500/20 text-red-400 border border-red-500/30 flex items-center justify-center hover:bg-red-500 hover:text-white">
                                    <i data-lucide="x" class="h-4 w-4"></i>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                <%
                            }
                            if (!foundStudents) {
                %>
                    <tr>
                        <td colspan="5" class="px-6 py-12 text-center text-slate-500">
                            <i data-lucide="folder-open" class="h-10 w-10 mx-auto mb-2 opacity-50"></i>
                            <p>No students found. Add one to get started.</p>
                        </td>
                    </tr>
                <%
                            }
                        } catch (Exception e) {
                %>
                    <tr>
                        <td colspan="5" class="px-6 py-6 text-center">
                            <div class="inline-flex items-center gap-2 text-red-400 bg-red-500/10 px-4 py-2 rounded-lg border border-red-500/20">
                                <i data-lucide="alert-circle" class="h-4 w-4"></i>
                                <span>Error loading data: <%= e.getMessage() %></span>
                            </div>
                        </td>
                    </tr>
                <%
                        } finally {
                             if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
                             if (ps != null) try { ps.close(); } catch (SQLException ignore) {}
                             if (con != null) try { con.close(); } catch (SQLException ignore) {}
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="5" class="px-6 py-6 text-center text-red-400">Database connection failed.</td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Navigation -->
    <div class="text-center mt-8">
        <a href="javascript:history.back()" class="inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-cyan-400 transition-colors">
            <i data-lucide="layout-dashboard" class="h-4 w-4"></i>
            <span>Back to Dashboard</span>
        </a>
    </div>

</div>

<!-- ADD STUDENT MODAL -->
<div id="addStudentModal" class="fixed inset-0 bg-slate-900/90 backdrop-blur-sm hidden z-50 transition-opacity flex items-center justify-center p-4">
    <div class="glass-card w-full max-w-md p-6 rounded-2xl relative border border-slate-700/50" onclick="event.stopPropagation();">

        <div class="flex justify-between items-center mb-6 border-b border-white/10 pb-4">
            <h3 class="text-xl font-bold text-white">Enroll Student</h3>
            <button onclick="document.getElementById('addStudentModal').classList.add('hidden')" class="text-slate-400 hover:text-white transition-colors">
                <i data-lucide="x" class="h-6 w-6"></i>
            </button>
        </div>

        <form method="post" class="space-y-4">
            <input type="hidden" name="action_type" value="add_student">

            <div>
                <label class="block text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Roll No</label>
                <input type="text" name="new_roll_no" required class="w-full bg-slate-800/80 border border-slate-600 rounded-lg px-4 py-2.5 text-white focus:border-cyan-500 focus:outline-none focus:ring-1 focus:ring-cyan-500 transition-all placeholder-slate-500" placeholder="e.g. H001">
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Full Name</label>
                <input type="text" name="new_name" required class="w-full bg-slate-800/80 border border-slate-600 rounded-lg px-4 py-2.5 text-white focus:border-cyan-500 focus:outline-none focus:ring-1 focus:ring-cyan-500 transition-all placeholder-slate-500" placeholder="Student Name">
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label class="block text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Room No</label>
                    <input type="text" name="new_room_no" required class="w-full bg-slate-800/80 border border-slate-600 rounded-lg px-4 py-2.5 text-white focus:border-cyan-500 focus:outline-none focus:ring-1 focus:ring-cyan-500 transition-all placeholder-slate-500" placeholder="e.g. 101">
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-400 uppercase tracking-wide mb-1">Fee Status</label>
                    <select name="new_fee_status" required class="w-full bg-slate-800/80 border border-slate-600 rounded-lg px-4 py-2.5 text-white focus:border-cyan-500 focus:outline-none focus:ring-1 focus:ring-cyan-500 transition-all [&>option]:bg-slate-800">
                        <option value="Paid">Paid</option>
                        <option value="Unpaid">Unpaid</option>
                        <option value="Partial">Partial</option>
                    </select>
                </div>
            </div>

            <button type="submit" class="w-full mt-2 bg-cyan-600 hover:bg-cyan-500 text-white font-bold py-3 rounded-xl shadow-lg shadow-cyan-900/20 flex items-center justify-center gap-2 transition-all">
                <i data-lucide="save" class="h-4 w-4"></i>
                <span>Save to Database</span>
            </button>
        </form>
    </div>
</div>

<script>
    lucide.createIcons();

    // Close modal on outside click
    document.getElementById('addStudentModal').addEventListener('click', (e) => {
        if (e.target.id === 'addStudentModal') e.target.classList.add('hidden');
    });
</script>

</body>
</html>
