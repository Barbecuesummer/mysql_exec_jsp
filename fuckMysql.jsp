<%@ page import="java.sql.*" %>
<%--
  Created by IntelliJ IDEA.
  User: baoyu
  Date: 2023/1/4
  Time: 16:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>fuckMysql</title>
    <script type="text/javascript">
        function exec_sql() {
            let form = document.getElementById("sb");
            form.check.value = "sql";
            form.submit();
        }
    </script>
</head>
<body>
<form name="sb" id="sb" action="#" method="post" >
    <input hidden id="check" name="check" value="check"/>
    <table style="border: 1px; table-layout: fixed" cellpadding="10">
        <tr>
            <td style="width: 10%;"><label>用户名：</label>
            <td><input  id="userName" name="userName" placeholder="root" value="" style="width: 83%;" required/></td>
        </tr>
        <tr>
            <td style="width: 10%;"><label>密码：</label>
            <td><input id="password" name="password" type="password" value="" style="width: 83%;" required/></td>
        </tr>
        <tr>
            <td style="width: 10%;"><label>数据库连接：</label>
            <td><input id="url" name="url" placeholder="jdbc:mysql://127.0.0.1:3306/数据库名称?useUnicode=true&characterEncoding=gbk&zeroDateTimeBehavior=convertToNull&useSSL=false"
                       value="" style="width: 83%;" required/></td>
        </tr>
        <tr>
            <td style="width: 10%;"><label>驱动：</label>
            <td><input id="driver" name="driver" placeholder="com.mysql.jdbc.Driver" value="com.mysql.jdbc.Driver" style="width: 83%;" required/></td>
        </tr>
        <tr>
            <td colspan="2" align="right"><button  style="margin-right: 175px" type="submit">链接测试</button></td>
        </tr>
        <tr>
            <td colspan="2" id="check_message" style="visibility: hidden; width: 100%" ><span id="message_detail" style="color: green">芜湖</span></td>
        </tr>
        <tr>
            <td colspan="2"><textarea id="sql" name="sql" style="height: 113px; width: 975px;"></textarea></td>
        </tr>
        <tr>
            <td colspan="2" align="right"><input type="button"  style="margin-right: 175px" value="SQL执行" onclick="exec_sql()"></td>
        </tr>
    </table>
</form>
<div id="my_div"></div>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String method = request.getMethod();
    if("POST".equals(method)) {
        if (request.getParameter("check") != null) {
            String userName = request.getParameter("userName");
            String password = request.getParameter("password");
            String driver = request.getParameter("driver");
            String url = request.getParameter("url");
            if(userName != null && !"".equals(userName) && password != null && !"".equals(password)
                    && driver != null && !"".equals(driver) && url != null && !"".equals(url)) {
                out.write("<script type=\"text/javascript\">\n" +
                        "        document.getElementById(\"userName\").value  =" + userName + ";\n" +
                        "        document.getElementById(\"password\").value  = " + password + ";\n" +
                        "        document.getElementById(\"url\").value  = " + url + ";\n" +
                        "        document.getElementById(\"driver\").value  = " + driver + ";\n" +
                        "    </script>");
            } else {
                out.write("<script type=\"text/javascript\">alert(\"你空着栏位不写是什么意思呢\");</script>");
                return;
            }

            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;
            out.write("<script type=\"text/javascript\">document.getElementById(\"check_message\").style.visibility = \"visible\";</script>");
            try {
                Class.forName(driver);
            } catch (ClassNotFoundException e) {
                e.printStackTrace();
                out.write("<script type=\"text/javascript\">document.getElementById(\"message_detail\").innerHTML = \"数据库驱动加载失败，你写错了吧哥们\";document.getElementById(\"message_detail\").style.color = \"red\";</script>");
                return;
            }
            if ("check".equals(request.getParameter("check"))) {
                try {
                    conn = DriverManager.getConnection(url, userName, password);
                    conn.close();
                    out.write("<script type=\"text/javascript\">document.getElementById(\"message_detail\").innerHTML = \"数据库能够连接上\";document.getElementById(\"message_detail\").style.color = \"green\";</script>");
                } catch (SQLException e) {
                    e.printStackTrace();
                    String message = e.getMessage().replace("\n", " ");
                    out.write("<script type=\"text/javascript\">document.getElementById(\"message_detail\").innerHTML = \"数据库连不上，报错信息是" + message +"\";document.getElementById(\"message_detail\").style.color = \"red\";</script>");
                    return;
                }

            } else if ("sql".equals(request.getParameter("check"))) {
                String sql = request.getParameter("sql");
                if (sql == null || "".equals(sql)) {
                    out.write("<script type=\"text/javascript\">document.getElementById(\"message_detail\").innerHTML = \"不写SQL你执行你🐎呢\";document.getElementById(\"message_detail\").style.color = \"red\";</script>");
                    return;
                }
                try {
                    conn = DriverManager.getConnection(url, userName, password);
                    stmt = conn.createStatement();
                    String curd = sql.substring(0, sql.indexOf(" ")).toUpperCase();
                    if ("SELECT".equals(curd)) {
                        rs = stmt.executeQuery(sql);
                        int columnCount = rs.getMetaData().getColumnCount();
                        int num = 0;
                        StringBuilder trData = new StringBuilder();
                        trData.append("<script type=\"text/javascript\"> let my_table = document.createElement('table');my_table.style.border = \"1px\";my_table.cellPadding = \"10\";\n" +
                                "        let my_div = document.getElementById(\"my_div\");my_div.appendChild(my_table);\n" +
                                "        let my_thead = document.createElement('thead');my_table.appendChild(my_thead);\n" +
                                "        let my_thead_tr = document.createElement('tr');my_thead_tr.style.backgroundColor = \"lightblue\";my_thead.appendChild(my_thead_tr);\n" +
                                "        let my_tbody = document.createElement('tbody');my_table.appendChild(my_tbody);\n" +
                                "        function setInnerText(element, content) {\n" +
                                "            if (typeof element.innerText === 'string') {\n" +
                                "                element.innerText = content;\n" +
                                "            } else {\n" +
                                "                element.textContent = content;\n" +
                                "            }\n" +
                                "        };\n");
                        while(rs.next())  {
                            StringBuilder tempTrData = new StringBuilder();
                            if (num == 0) {
                                for (int i = 1; i <= columnCount; i++) {
                                    String columnName = rs.getMetaData().getColumnName(i);
                                    tempTrData.append("let my_th").append(i).append("= document.createElement('th');setInnerText(my_th").
                                            append(i).append(",").append("'").append(columnName).append("'").append(");my_thead_tr.appendChild(my_th").
                                            append(i).append(");");
                                }
                                trData.append(tempTrData);
                            }
                            tempTrData = new StringBuilder("let my_tbody_tr" + num + " = document.createElement('tr');my_tbody.appendChild(my_tbody_tr"+ num +");");
                            StringBuilder tempTdData = new StringBuilder();
                            for (int i = 1; i <= columnCount; i++) {
                                int columnType = rs.getMetaData().getColumnType(i);
                                String value = getStringByType(columnType, rs, i);
                                tempTdData.append("let my_td_").append(num).append("_").append(i).
                                        append(" = document.createElement('td');setInnerText(my_td_").
                                        append(num).append("_").append(i).append(",").append("'").append(value).append("'").append(");").
                                        append("my_tbody_tr").append(num).
                                        append(".appendChild(my_td_").append(num).append("_").append(i).append(");");
                            }
                            tempTrData.append(tempTdData.toString());
                            trData.append(tempTrData);
                            num ++;
                        }
                        out.write(trData.toString() + "</script>");
                    } else {
                        boolean execute = stmt.execute(sql);
                        if (execute) {
                            out.write("<script type=\"text/javascript\">document.getElementById(\"message_detail\").innerHTML = \"语句执行成功\";document.getElementById(\"message_detail\").style.color = \"green\";</script>");
                        } else {
                            out.write("<script type=\"text/javascript\">document.getElementById(\"message_detail\").innerHTML = \"语句执行成功，影响行数为 + " + stmt.getUpdateCount() + "\";document.getElementById(\"message_detail\").style.color = \"green\";</script>");
                        }
                    }
                } catch (SQLException e) {
                    String message = e.getMessage().replace("\n", " ");
                    out.write("<script type=\"text/javascript\">document.getElementById(\"message_detail\").innerHTML = \"SQL执行报错了哥们，报错信息是" + message +"\";document.getElementById(\"message_detail\").style.color = \"red\";</script>");
                    return;
                }
                out.write("<script type=\"text/javascript\">alert(\"执行成功哥们\");</script>");
            }
        }
    }
%>
<%!
private String getStringByType(int type, ResultSet resultSet,int i) throws SQLException {
    String value = "";
    switch (type) {
        case Types.BIGINT:
            value += resultSet.getLong(i);
            break;
        case Types.BIT:
        case Types.BOOLEAN:
            value += resultSet.getBoolean(i);
            break;
        case Types.CHAR:
        case Types.VARCHAR:
            value += resultSet.getString(i);
            break;
        case Types.DATE:
            value += resultSet.getDate(i) + "";
            break;
        case Types.DECIMAL:
        case Types.NUMERIC:
        case Types.REAL:
        case Types.DOUBLE:
            value += resultSet.getDouble(i);
            break;
        case Types.FLOAT:
            value += resultSet.getFloat(i);
            break;
        case Types.INTEGER:
            value += resultSet.getInt(i);
            break;
        case Types.TINYINT:
            value += resultSet.getShort(i);
            break;
        case Types.TIME:
            value += resultSet.getTime(i) + "";
            break;
        case Types.DATALINK:
            value += resultSet.getTimestamp(i) + "";
            break;
    }
    return value;
}
%>
</body>
</html>
