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

        // QUERY 1: Get fee status counts for summary
        ps = con.prepareStatement("SELECT fee_status FROM students");
        rs = ps.executeQuery();

        while (rs.next()) {
            total++;
            String status = rs.getString("fee_status");
            if ("Paid".equalsIgnoreCase(status)) {
                paid++;
            } else {
                unpaid++; // Counts 'Unpaid' and 'Partial' as pending for this summary
            }
        }
        // Resources closed in finally block or reused below
    } catch (Exception e) {
        // Error handled in UI
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fee Reports | Admin Console</title>

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

        .glass-panel {
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: all 0.3s ease;
        }
        .glass-panel:hover {
            transform: translateY(-4px);
            border-color: rgba(255, 255, 255, 0.1);
            background: rgba(30, 41, 59, 0.8);
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
        .status-Paid { background: rgba(16, 185, 129, 0.1); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.2); }
        .status-Unpaid { background: rgba(239, 68, 68, 0.1); color: #f87171; border: 1px solid rgba(239, 68, 68, 0.2); }
        .status-Partial { background: rgba(245, 158, 11, 0.1); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.2); }
        .status-NA { background: rgba(148, 163, 184, 0.1); color: #94a3b8; border: 1px solid rgba(148, 163, 184, 0.2); }

    </style>
</head>

<body class="p-4 sm:p-6 min-h-screen">

<div class="max-w-7xl mx-auto animate-fade-in-up">

    <!-- Header -->
    <div class="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
        <div>
            <h2 class="text-3xl font-bold text-white tracking-tight">Fee Reports</h2>
            <div class="flex items-center gap-2 mt-1 text-slate-400">
                <i data-lucide="bar-chart-3" class="h-4 w-4"></i>
                <span class="text-sm">Financial overview and status tracking</span>
            </div>
        </div>

        <div class="flex items-center gap-3">
            <button onclick="window.print()" class="group bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white font-medium py-2.5 px-5 rounded-xl border border-slate-700 hover:border-slate-500 transition-all flex items-center gap-2 text-sm">
                <i data-lucide="printer" class="h-4 w-4 text-slate-500 group-hover:text-white"></i>
                <span>Print Report</span>
            </button>
            <a href="hostel.jsp" class="group flex items-center gap-2 px-5 py-2.5 rounded-xl bg-slate-800/50 border border-slate-700 hover:border-cyan-500/50 transition-all text-sm font-medium text-slate-300 hover:text-white">
                <i data-lucide="layout-dashboard" class="h-4 w-4 group-hover:-translate-x-1 transition-transform"></i>
                Dashboard
            </a>
        </div>
    </div>

    <!-- KPI Widgets -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">

        <!-- Total Students -->
        <div class="glass-panel p-6 rounded-2xl border-l-4 border-l-indigo-500 relative overflow-hidden group">
            <div class="absolute right-0 top-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                <i data-lucide="users" class="h-24 w-24 text-indigo-400"></i>
            </div>
            <p class="text-xs font-bold text-indigo-400 uppercase tracking-wider mb-1">Total Students</p>
            <h3 class="text-4xl font-bold text-white"><%= total %></h3>
            <p class="text-xs text-slate-500 mt-2">Registered in database</p>
        </div>

        <!-- Paid -->
        <div class="glass-panel p-6 rounded-2xl border-l-4 border-l-emerald-500 relative overflow-hidden group">
            <div class="absolute right-0 top-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                <i data-lucide="check-circle-2" class="h-24 w-24 text-emerald-400"></i>
            </div>
            <p class="text-xs font-bold text-emerald-400 uppercase tracking-wider mb-1">Fee Cleared</p>
            <h3 class="text-4xl font-bold text-white"><%= paid %></h3>
            <p class="text-xs text-slate-500 mt-2">Fully paid accounts</p>
        </div>

        <!-- Unpaid -->
        <div class="glass-panel p-6 rounded-2xl border-l-4 border-l-red-500 relative overflow-hidden group">
            <div class="absolute right-0 top-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                <i data-lucide="alert-octagon" class="h-24 w-24 text-red-400"></i>
            </div>
            <p class="text-xs font-bold text-red-400 uppercase tracking-wider mb-1">Pending Dues</p>
            <h3 class="text-4xl font-bold text-white"><%= unpaid %></h3>
            <p class="text-xs text-slate-500 mt-2">Action required</p>
        </div>
    </div>

    <!-- Main Data Table -->
    <div class="glass-card rounded-2xl overflow-hidden border border-slate-700/50">
        <div class="p-5 border-b border-slate-700/50 bg-slate-900/50 flex justify-between items-center">
            <h3 class="font-bold text-white flex items-center gap-2">
                <i data-lucide="list-filter" class="h-4 w-4 text-cyan-400"></i>
                Detailed Status
            </h3>
            <!-- Legend -->
            <div class="hidden sm:flex gap-3 text-[10px] font-bold uppercase tracking-wider">
                <span class="flex items-center gap-1 text-emerald-400"><span class="w-2 h-2 rounded-full bg-emerald-500"></span> Paid</span>
                <span class="flex items-center gap-1 text-red-400"><span class="w-2 h-2 rounded-full bg-red-500"></span> Unpaid</span>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left border-collapse">
                <thead class="table-header">
                    <tr>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">Roll No</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">Student Name</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">Room Allocation</th>
                        <th class="px-6 py-4 text-xs font-bold text-cyan-300 uppercase tracking-wider">Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-white/5">

                <%
                    // QUERY 2: Get detailed student list
                    try {
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
                            if (status == null) status = "NA";

                            // Highlight logic for unpaid
                            boolean isUnpaid = "Unpaid".equalsIgnoreCase(status) || "Partial".equalsIgnoreCase(status);
                %>

                    <tr class="table-row group">
                        <td class="px-6 py-4">
                            <span class="font-mono text-sm font-bold text-white bg-slate-800/50 border border-slate-700 px-2 py-1 rounded"><%= rollNo %></span>
                        </td>
                        <td class="px-6 py-4">
                            <div class="flex items-center gap-3">
                                <div class="h-8 w-8 rounded-full flex items-center justify-center text-xs font-bold border
                                    <%= isUnpaid ? "bg-red-500/10 text-red-400 border-red-500/20" : "bg-cyan-500/10 text-cyan-400 border-cyan-500/20" %>">
                                    <%= name.substring(0, 1) %>
                                </div>
                                <span class="text-sm font-medium text-slate-200 group-hover:text-white transition-colors"><%= name %></span>
                            </div>
                        </td>
                        <td class="px-6 py-4 text-sm text-slate-400">
                            <% if (roomNo != null) { %>
                                <span class="flex items-center gap-2">
                                    <i data-lucide="door-closed" class="h-3 w-3"></i> <%= roomNo %>
                                </span>
                            <% } else { %>
                                <span class="text-slate-600 italic">Not Allocated</span>
                            <% } %>
                        </td>
                        <td class="px-6 py-4">
                            <span class="px-2.5 py-1 inline-flex text-[10px] leading-5 font-bold uppercase tracking-widest rounded-full <%= "status-" + status %>">
                                <%= status %>
                            </span>
                        </td>
                    </tr>

                <%
                        }

                        if (!foundDetails) {
                %>
                    <tr>
                        <td colspan="4" class="px-6 py-12 text-center text-slate-500">
                            <i data-lucide="search-x" class="h-10 w-10 mx-auto mb-2 opacity-50"></i>
                            <p>No student records found.</p>
                        </td>
                    </tr>
                <%
                        }
                    } catch (Exception e) {
                %>
                    <tr>
                        <td colspan="4" class="px-6 py-6 text-center">
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

<script>
    lucide.createIcons();
</script>

</body>
</html>
