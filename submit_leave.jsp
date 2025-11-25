<%@ page import="java.sql.*" %>
<%
    String msg = "";

    if (request.getMethod().equals("POST")) {
        String u = request.getParameter("roll");
        String p = request.getParameter("password");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hostel_db",
                    "root",
                    "admin"
            );

            PreparedStatement ps = con.prepareStatement(
                "SELECT * FROM students WHERE roll_no=? AND password=?"
            );
            ps.setString(1, u);
            ps.setString(2, p);

            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                session.setAttribute("student", u);
                response.sendRedirect("hostel.jsp?user=student");
                return;
            } else {
                msg = "Invalid Login Credentials!";
            }
            con.close();

        } catch (Exception e) {
            msg = "Connection Error: " + e.getMessage();
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Login - Secure Access</title>

    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500&family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">

    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #0b0f19;
            /* Student Theme Background Gradient */
            background-image:
                radial-gradient(circle at 10% 10%, rgba(168, 85, 247, 0.15) 0%, transparent 40%),
                radial-gradient(circle at 90% 90%, rgba(79, 70, 229, 0.15) 0%, transparent 40%);
            min-height: 100vh;
        }

        h1, h2 { font-family: 'Space Grotesk', sans-serif; }

        /* --- Glass Card --- */
        .login-card {
            background: rgba(17, 24, 39, 0.75);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.08);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
        }

        /* --- Input Fields --- */
        .input-group { position: relative; }

        .custom-input {
            background: rgba(15, 23, 42, 0.6);
            border: 1px solid rgba(255, 255, 255, 0.1);
            color: #e2e8f0;
            transition: all 0.3s ease;
        }

        .custom-input:focus {
            border-color: #a855f7; /* Purple 500 */
            box-shadow: 0 0 0 4px rgba(168, 85, 247, 0.1);
            outline: none;
            background: rgba(15, 23, 42, 0.8);
        }

        /* --- Electric Button --- */
        .glow-btn {
            background: linear-gradient(135deg, #a855f7, #7c3aed);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .glow-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px -5px rgba(168, 85, 247, 0.4);
        }

        .glow-btn:active { transform: scale(0.98); }

        /* --- Animation --- */
        @keyframes pulse-slow {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }
        .animate-pulse-slow {
            animation: pulse-slow 3s cubic-bezier(0.4, 0, 0.6, 1) infinite;
        }

    </style>
</head>
<body class="flex items-center justify-center p-4">

    <div class="w-full max-w-md login-card rounded-2xl p-8 shadow-2xl relative overflow-hidden">

        <div class="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-purple-500 to-transparent opacity-80"></div>

        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center h-16 w-16 rounded-full bg-purple-500/10 border border-purple-500/20 mb-4 animate-pulse-slow">
                <i data-lucide="user" class="h-8 w-8 text-purple-400"></i>
            </div>
            <h2 class="text-3xl font-bold text-white tracking-tight">Student Access</h2>
            <p class="text-slate-400 text-sm mt-2">Enter your credentials to continue</p>
        </div>

        <form method="post" class="space-y-5">

            <div class="input-group">
                <label class="block text-xs font-medium text-slate-400 mb-1 uppercase tracking-wider">Roll Number</label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <i data-lucide="hash" class="h-5 w-5 text-slate-500"></i>
                    </div>
                    <input type="text" name="roll" required
                        class="custom-input w-full rounded-lg py-3 pl-10 pr-4 text-sm placeholder-slate-600"
                        placeholder="e.g. 2023CS01">
                </div>
            </div>

            <div class="input-group">
                <label class="block text-xs font-medium text-slate-400 mb-1 uppercase tracking-wider">Password</label>
                <div class="relative">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <i data-lucide="lock" class="h-5 w-5 text-slate-500"></i>
                    </div>
                    <input type="password" name="password" required
                        class="custom-input w-full rounded-lg py-3 pl-10 pr-4 text-sm placeholder-slate-600"
                        placeholder="••••••••">
                </div>
            </div>

            <% if (!msg.isEmpty()) { %>
            <div class="flex items-center gap-2 bg-red-500/10 border border-red-500/20 text-red-400 px-4 py-3 rounded-lg text-sm" role="alert">
                <i data-lucide="alert-circle" class="h-4 w-4"></i>
                <span><%= msg %></span>
            </div>
            <% } %>

            <button class="glow-btn w-full text-white font-bold py-3.5 rounded-lg flex items-center justify-center gap-2 group mt-2">
                <span>Secure Login</span>
                <i data-lucide="arrow-right" class="h-5 w-5 group-hover:translate-x-1 transition-transform"></i>
            </button>

        </form>

        <div class="mt-6 text-center">
            <a href="javascript:history.back()" class="text-sm text-slate-500 hover:text-purple-400 transition-colors flex items-center justify-center gap-1 cursor-pointer">
                <i data-lucide="arrow-left" class="h-3 w-3"></i>
                Back to Portal Selection
            </a>
        </div>

    </div>

    <script>
        lucide.createIcons();
    </script>

</body>
</html>
