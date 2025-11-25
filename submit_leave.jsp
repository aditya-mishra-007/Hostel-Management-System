<%@ page import="java.sql.*" %>

<%
    // --- AUTHENTICATION CHECK ---
    if (session.getAttribute("student") == null) {
        response.sendRedirect("student_login.jsp");
        return;
    }

    // Retrieve Roll No (Prioritizing specific attribute, falling back to generic)
    String roll_no = null;
    String name = null;

    if (session.getAttribute("student_roll") != null) {
        roll_no = (String) session.getAttribute("student_roll");
    } else if (session.getAttribute("student") != null && session.getAttribute("student") instanceof String) {
        roll_no = (String) session.getAttribute("student");
    }

    // Retrieve Name
    name = (String) session.getAttribute("student_name");

    // Default database details
    String DB_URL = "jdbc:mysql://localhost:3306/hostel_db?useSSL=false&serverTimezone=UTC";
    String DB_USER = "root";
    String DB_PASS = "admin";

    String message = "";
    String messageType = ""; // success or error

    // --- CRITICAL CHECK ---
    if (roll_no == null || roll_no.isEmpty()) {
        message = "🛑 Error: Could not retrieve your Roll Number. Please log in again.";
        messageType = "error";
    }

    // Handle Form Submission
    if (request.getParameter("submit") != null && (roll_no != null && !roll_no.isEmpty())) {

        String reason = request.getParameter("reason");
        String from = request.getParameter("from_date");
        String to = request.getParameter("to_date");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            PreparedStatement ps = con.prepareStatement(
                "INSERT INTO leave_requests (roll_no, name, reason, from_date, to_date, status) VALUES (?,?,?,?,?,?)"
            );

            ps.setString(1, roll_no);
            ps.setString(2, (name != null ? name : "Unknown Student"));
            ps.setString(3, reason);
            ps.setString(4, from);
            ps.setString(5, to);
            ps.setString(6, "Pending");

            if (ps.executeUpdate() > 0) {
                message = "Request submitted successfully! Awaiting admin approval.";
                messageType = "success";
            } else {
                message = "Submission failed. Please try again.";
                messageType = "error";
            }

            con.close();

        } catch (Exception e) {
            message = "Database Error: " + e.getMessage();
            messageType = "error";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Submit Leave Request</title>

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>
    <!-- Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0b0f19;
            /* Student Theme Background Gradient */
            background-image:
                radial-gradient(circle at 10% 20%, rgba(168, 85, 247, 0.15) 0%, transparent 40%),
                radial-gradient(circle at 90% 80%, rgba(79, 70, 229, 0.15) 0%, transparent 40%);
            min-height: 100vh;
            color: #e2e8f0;
        }

        h1, h2, h3 { font-family: 'Space Grotesk', sans-serif; }

        /* --- GLASS COMPONENTS --- */
        .glass-card {
            background: rgba(30, 41, 59, 0.4);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.05);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }

        /* --- INPUT STYLING --- */
        .custom-input {
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: #e2e8f0;
            transition: all 0.3s ease;
        }
        .custom-input:focus {
            background: rgba(15, 23, 42, 0.8);
            border-color: #a855f7;
            box-shadow: 0 0 0 2px rgba(168, 85, 247, 0.2);
            outline: none;
        }

        /* Force dark date picker */
        input[type="date"] {
            color-scheme: dark;
        }

        /* --- BUTTON GLOW --- */
        .glow-btn {
            background: linear-gradient(135deg, #a855f7, #6366f1);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .glow-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 0 20px rgba(168, 85, 247, 0.4);
        }

        /* --- ALERTS --- */
        .alert-success {
            background: rgba(34, 197, 94, 0.1);
            border: 1px solid rgba(34, 197, 94, 0.2);
            color: #4ade80;
        }
        .alert-error {
            background: rgba(239, 68, 68, 0.1);
            border: 1px solid rgba(239, 68, 68, 0.2);
            color: #f87171;
        }

    </style>
</head>

<body class="flex flex-col items-center justify-center min-h-screen p-4 sm:p-6">

<div class="w-full max-w-lg animate-fade-in-up">

    <!-- Header -->
    <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center h-16 w-16 rounded-2xl bg-gradient-to-br from-purple-500/20 to-indigo-500/20 border border-white/10 mb-4 shadow-lg shadow-purple-500/10">
            <i data-lucide="send" class="h-8 w-8 text-purple-400"></i>
        </div>
        <h2 class="text-4xl font-bold text-white tracking-tight">Apply for Leave</h2>
        <p class="text-slate-400 mt-2">Submit your outpass request for approval.</p>
    </div>

    <!-- Main Glass Form -->
    <div class="glass-card rounded-2xl p-8 relative overflow-hidden">

        <!-- Decorative Top Border -->
        <div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-purple-500 to-transparent opacity-70"></div>

        <%-- Message Display --%>
        <% if (!message.isEmpty()) { %>
            <div class="mb-6 p-4 rounded-xl flex items-start gap-3 <%= "success".equals(messageType) ? "alert-success" : "alert-error" %>">
                <% if ("success".equals(messageType)) { %>
                    <i data-lucide="check-circle-2" class="h-5 w-5 shrink-0 mt-0.5"></i>
                <% } else { %>
                    <i data-lucide="alert-octagon" class="h-5 w-5 shrink-0 mt-0.5"></i>
                <% } %>
                <div>
                    <h4 class="font-bold text-sm uppercase tracking-wide mb-1"><%= "success".equals(messageType) ? "Success" : "Error" %></h4>
                    <p class="text-sm opacity-90"><%= message %></p>
                </div>
            </div>
        <% } %>

        <form method="post" class="space-y-6">

            <!-- Roll No Display -->
            <div class="flex items-center justify-between p-3 rounded-lg bg-white/5 border border-white/10">
                <span class="text-xs font-bold text-slate-400 uppercase tracking-wider">Applicant Roll No</span>
                <span class="text-sm font-mono font-bold text-purple-300"><%= roll_no != null ? roll_no : "N/A" %></span>
            </div>

            <!-- Reason Input -->
            <div>
                <label for="reason" class="block text-xs font-bold text-slate-300 uppercase tracking-wide mb-2">Reason for Leave</label>
                <textarea id="reason" name="reason" rows="3" required
                    class="custom-input w-full rounded-xl px-4 py-3 text-sm placeholder-slate-600 resize-none"
                    placeholder="e.g. Going home for family function..."></textarea>
            </div>

            <!-- Dates Grid -->
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                    <label for="from_date" class="block text-xs font-bold text-slate-300 uppercase tracking-wide mb-2">From Date</label>
                    <div class="relative">
                        <input type="date" id="from_date" name="from_date" required
                            class="custom-input w-full rounded-xl px-4 py-3 text-sm text-slate-200">
                    </div>
                </div>

                <div>
                    <label for="to_date" class="block text-xs font-bold text-slate-300 uppercase tracking-wide mb-2">To Date</label>
                    <div class="relative">
                        <input type="date" id="to_date" name="to_date" required
                            class="custom-input w-full rounded-xl px-4 py-3 text-sm text-slate-200">
                    </div>
                </div>
            </div>

            <!-- Submit Button -->
            <button type="submit" name="submit"
                class="glow-btn w-full text-white font-bold py-4 rounded-xl shadow-lg flex items-center justify-center gap-2 group mt-2">
                <i data-lucide="send" class="h-5 w-5 group-hover:-translate-y-1 group-hover:translate-x-1 transition-transform"></i>
                <span>Submit Request</span>
            </button>

        </form>

    </div>

    <!-- Back Link -->
    <div class="text-center mt-8">
        <a href="hostel.jsp"
           class="inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-purple-400 transition-colors">
            <i data-lucide="arrow-left" class="h-4 w-4"></i>
            <span>Back to Dashboard</span>
        </a>
    </div>
</div>

<script>
    lucide.createIcons();
</script>
</body>
</html>
