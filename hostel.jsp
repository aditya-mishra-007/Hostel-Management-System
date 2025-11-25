<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    // --- BACKEND LOGIC ---
    String admin = (String)session.getAttribute("admin");
    String student = (String)session.getAttribute("student");

    String role = null;
    String themeColor = "purple"; // Default Student Theme
    String accentColor = "a855f7"; // Purple-500 Hex
    String greetingName = "Guest";
    String badgeText = "Guest Access";

    if (admin != null) {
        role = "admin";
        themeColor = "cyan"; // Admin Theme
        accentColor = "06b6d4"; // Cyan-500
        greetingName = admin;
        badgeText = "Administrator";
    } else if (student != null) {
        role = "student";
        themeColor = "purple"; // Student Theme
        accentColor = "a855f7";
        greetingName = student;
        badgeText = "Student Resident";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Hostel Portal</title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">

    <style>
        /* --- GLOBAL THEME --- */
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0b0f19; /* Deep Midnight */
            min-height: 100vh;
            color: #e2e8f0;
            overflow-x: hidden;
        }

        h1, h2, h3 { font-family: 'Space Grotesk', sans-serif; }

        /* Dynamic Background Gradients */
        .bg-theme-admin {
            background-image:
                radial-gradient(circle at 0% 0%, rgba(6, 182, 212, 0.15) 0%, transparent 50%),
                radial-gradient(circle at 100% 100%, rgba(16, 185, 129, 0.1) 0%, transparent 50%);
        }
        .bg-theme-student {
            background-image:
                radial-gradient(circle at 0% 0%, rgba(168, 85, 247, 0.15) 0%, transparent 50%),
                radial-gradient(circle at 100% 100%, rgba(79, 70, 229, 0.1) 0%, transparent 50%);
        }

        /* --- GLASS COMPONENTS --- */
        .glass-nav {
            background: rgba(15, 23, 42, 0.7);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.05);
            position: sticky;
            top: 0;
            z-index: 50;
        }

        .glass-card {
            background: rgba(30, 41, 59, 0.4); /* Semi-transparent Slate */
            backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* --- INTERACTIVE ACTION CARDS --- */
        .action-card {
            position: relative;
            overflow: hidden;
        }

        .action-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background: linear-gradient(135deg, rgba(255,255,255,0.05), transparent);
            opacity: 0;
            transition: opacity 0.3s;
        }

        .action-card:hover {
            transform: translateY(-4px);
            background: rgba(30, 41, 59, 0.6);
        }
        .action-card:hover::before { opacity: 1; }

        /* Admin Hover Theme */
        .theme-cyan .action-card:hover {
            border-color: #06b6d4;
            box-shadow: 0 10px 30px -10px rgba(6, 182, 212, 0.3);
        }
        .theme-cyan .icon-box { color: #22d3ee; background: rgba(6, 182, 212, 0.1); }
        .theme-cyan .action-card:hover .icon-box { background: #06b6d4; color: white; }

        /* Student Hover Theme */
        .theme-purple .action-card:hover {
            border-color: #a855f7;
            box-shadow: 0 10px 30px -10px rgba(168, 85, 247, 0.3);
        }
        .theme-purple .icon-box { color: #c084fc; background: rgba(168, 85, 247, 0.1); }
        .theme-purple .action-card:hover .icon-box { background: #a855f7; color: white; }

        .icon-box { transition: all 0.3s ease; }

    </style>
</head>
<body class="<%= role != null && role.equals("admin") ? "bg-theme-admin theme-cyan" : "bg-theme-student theme-purple" %>">

    <!-- Navbar -->
    <nav class="glass-nav w-full">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex items-center justify-between h-20">

                <!-- Logo Area -->
                <div class="flex items-center gap-3">
                    <div class="h-10 w-10 rounded-xl bg-gradient-to-br <%= role != null && role.equals("admin") ? "from-cyan-500 to-emerald-500" : "from-purple-500 to-indigo-500" %> flex items-center justify-center shadow-lg">
                        <i data-lucide="building-2" class="h-6 w-6 text-white"></i>
                    </div>
                    <div>
                        <h1 class="text-xl font-bold text-white tracking-tight">Hostel<span class="opacity-50 font-normal">Portal</span></h1>
                    </div>
                </div>

                <% if (role != null) { %>
                    <!-- User Profile & Logout -->
                    <div class="flex items-center gap-6">
                        <div class="hidden md:flex flex-col items-end">
                            <span class="text-sm font-bold text-white"><%= greetingName %></span>
                            <span class="text-xs px-2 py-0.5 rounded-full bg-white/10 text-white/70 border border-white/5">
                                <%= badgeText %>
                            </span>
                        </div>

                        <a href="logout.jsp" class="group flex items-center justify-center h-10 w-10 rounded-full bg-red-500/10 border border-red-500/20 hover:bg-red-500 hover:text-white transition-all duration-300 text-red-400" title="Logout">
                            <i data-lucide="power" class="h-5 w-5"></i>
                        </a>
                    </div>
                <% } %>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">

        <% if (role != null) { %>

            <!-- Welcome Header -->
            <div class="mb-10 animate-fade-in-up">
                <h2 class="text-4xl md:text-5xl font-bold text-white mb-2">
                    Dashboard
                </h2>
                <p class="text-slate-400 text-lg">
                    Manage your hostel activities and status.
                </p>
            </div>

            <!-- Dashboard Grid -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

                <% if (role.equals("admin")) { %>
                    <!-- ADMIN ACTIONS -->

                    <a href="view_students.jsp" class="glass-card action-card p-6 rounded-2xl flex flex-col justify-between h-48 group">
                        <div class="flex justify-between items-start">
                            <div class="icon-box h-12 w-12 rounded-lg flex items-center justify-center">
                                <i data-lucide="users" class="h-6 w-6"></i>
                            </div>
                            <i data-lucide="arrow-up-right" class="h-5 w-5 text-slate-500 group-hover:text-white transition-colors"></i>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-white group-hover:translate-x-1 transition-transform">All Students</h3>
                            <p class="text-sm text-slate-400 mt-1">Directory & profiles</p>
                        </div>
                    </a>

                    <a href="manage_rooms.jsp" class="glass-card action-card p-6 rounded-2xl flex flex-col justify-between h-48 group">
                        <div class="flex justify-between items-start">
                            <div class="icon-box h-12 w-12 rounded-lg flex items-center justify-center">
                                <i data-lucide="bed-double" class="h-6 w-6"></i>
                            </div>
                            <i data-lucide="arrow-up-right" class="h-5 w-5 text-slate-500 group-hover:text-white transition-colors"></i>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-white group-hover:translate-x-1 transition-transform">Room Manager</h3>
                            <p class="text-sm text-slate-400 mt-1">Allocation & capacity</p>
                        </div>
                    </a>

                    <a href="pending_requests.jsp" class="glass-card action-card p-6 rounded-2xl flex flex-col justify-between h-48 group">
                        <div class="flex justify-between items-start">
                            <div class="icon-box h-12 w-12 rounded-lg flex items-center justify-center">
                                <i data-lucide="bell-ring" class="h-6 w-6"></i>
                            </div>
                            <span class="flex h-3 w-3 relative">
                                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75"></span>
                                <span class="relative inline-flex rounded-full h-3 w-3 bg-red-500"></span>
                            </span>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-white group-hover:translate-x-1 transition-transform">Requests</h3>
                            <p class="text-sm text-slate-400 mt-1">Approve leaves/outpasses</p>
                        </div>
                    </a>

                    <a href="fee_reports.jsp" class="glass-card action-card p-6 rounded-2xl flex flex-col justify-between h-48 group">
                        <div class="flex justify-between items-start">
                            <div class="icon-box h-12 w-12 rounded-lg flex items-center justify-center">
                                <i data-lucide="wallet" class="h-6 w-6"></i>
                            </div>
                            <i data-lucide="arrow-up-right" class="h-5 w-5 text-slate-500 group-hover:text-white transition-colors"></i>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-white group-hover:translate-x-1 transition-transform">Finance</h3>
                            <p class="text-sm text-slate-400 mt-1">Fee status & dues</p>
                        </div>
                    </a>

                <% } else { %>
                    <!-- STUDENT ACTIONS -->

                    <a href="attendance.jsp?roll=<%= student %>" class="glass-card action-card p-6 rounded-2xl flex flex-col justify-between h-48 group">
                        <div class="flex justify-between items-start">
                            <div class="icon-box h-12 w-12 rounded-lg flex items-center justify-center">
                                <i data-lucide="calendar-check" class="h-6 w-6"></i>
                            </div>
                            <i data-lucide="arrow-up-right" class="h-5 w-5 text-slate-500 group-hover:text-white transition-colors"></i>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-white group-hover:translate-x-1 transition-transform">My Attendance</h3>
                            <p class="text-sm text-slate-400 mt-1">Check daily logs</p>
                        </div>
                    </a>

                    <a href="submit_leave.jsp" class="glass-card action-card p-6 rounded-2xl flex flex-col justify-between h-48 group">
                        <div class="flex justify-between items-start">
                            <div class="icon-box h-12 w-12 rounded-lg flex items-center justify-center">
                                <i data-lucide="send" class="h-6 w-6"></i>
                            </div>
                            <i data-lucide="arrow-up-right" class="h-5 w-5 text-slate-500 group-hover:text-white transition-colors"></i>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-white group-hover:translate-x-1 transition-transform">Apply Leave</h3>
                            <p class="text-sm text-slate-400 mt-1">Request outpass</p>
                        </div>
                    </a>

                    <a href="view_room.jsp" class="glass-card action-card p-6 rounded-2xl flex flex-col justify-between h-48 group">
                        <div class="flex justify-between items-start">
                            <div class="icon-box h-12 w-12 rounded-lg flex items-center justify-center">
                                <i data-lucide="home" class="h-6 w-6"></i>
                            </div>
                            <i data-lucide="arrow-up-right" class="h-5 w-5 text-slate-500 group-hover:text-white transition-colors"></i>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-white group-hover:translate-x-1 transition-transform">My Room</h3>
                            <p class="text-sm text-slate-400 mt-1">Roommates & details</p>
                        </div>
                    </a>

                    <a href="fee_details.jsp" class="glass-card action-card p-6 rounded-2xl flex flex-col justify-between h-48 group">
                        <div class="flex justify-between items-start">
                            <div class="icon-box h-12 w-12 rounded-lg flex items-center justify-center">
                                <i data-lucide="credit-card" class="h-6 w-6"></i>
                            </div>
                            <i data-lucide="arrow-up-right" class="h-5 w-5 text-slate-500 group-hover:text-white transition-colors"></i>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-white group-hover:translate-x-1 transition-transform">Payments</h3>
                            <p class="text-sm text-slate-400 mt-1">Dues & history</p>
                        </div>
                    </a>

                <% } %>
            </div>

        <% } else { %>

            <!-- ACCESS DENIED / NOT LOGGED IN STATE -->
            <div class="flex flex-col items-center justify-center min-h-[60vh]">
                <div class="glass-card p-10 rounded-3xl text-center max-w-lg border-red-500/20 shadow-2xl relative overflow-hidden">
                    <!-- Background Glow -->
                    <div class="absolute top-0 left-0 w-full h-1 bg-red-500"></div>
                    <div class="absolute -top-10 -left-10 w-32 h-32 bg-red-500/20 blur-3xl rounded-full pointer-events-none"></div>

                    <div class="h-20 w-20 bg-red-500/10 rounded-full flex items-center justify-center mx-auto mb-6 border border-red-500/20">
                        <i data-lucide="shield-alert" class="h-10 w-10 text-red-500"></i>
                    </div>

                    <h2 class="text-3xl font-bold text-white mb-2">Access Restricted</h2>
                    <p class="text-slate-400 mb-8">You must be authenticated to view this secure dashboard.</p>

                    <a href="index.html" class="inline-flex items-center gap-2 bg-red-600 hover:bg-red-700 text-white font-semibold py-3 px-8 rounded-xl transition-all shadow-lg shadow-red-600/20">
                        <i data-lucide="log-in" class="h-5 w-5"></i>
                        Login Now
                    </a>
                </div>
            </div>

        <% } %>

    </main>

    <script>
        lucide.createIcons();
    </script>
</body>
</html>
