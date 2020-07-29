---
layout: post
title:  "How To Use One-to-Many Database Relationships with Flask and SQLite"
author: "Full"
categories: [ database ]
description: "fake body!!!"
image: "https://sergio.afanou.com/assets/images/image-midres-48.jpg"
---


<p><em>The author selected the <a href="https://www.brightfunds.org/funds/write-for-donations-covid-19-relief-fund">COVID-19 Relief Fund</a> to receive a donation as part of the <a href="https://do.co/w4do-cta">Write for DOnations</a> program.</em></p>

<h3 id="introduction">Introduction</h3>

<p><a href="http://flask.pocoo.org/">Flask</a> is a framework for building web applications using the Python language, and <a href="https://sqlite.org/">SQLite</a> is a database engine that can be used with Python to store application data. In this tutorial, you will use Flask with SQLite to create a to-do application where users can create lists of to-do items. You will learn how to use SQLite with Flask and how one-to-many database relationships work.</p>

<p>A <em>one-to-many database relationship</em> is a relationship between two database tables where a record in one table can reference several records in another table. For example, in a blogging application, a table for storing posts can have a one-to-many relationship with a table for storing comments. Each post can reference many comments, and each comment references a single post; therefore, <strong>one</strong> post has a relationship with <strong>many</strong> comments. The post table is a <em>parent table</em>, while the comments table is a <em>child table</em>—a record in the parent table can reference many records in the child table. This is important to be able to have access to related data in each table.</p>

<p>We&rsquo;ll use SQLite because it is portable and does not need any additional set up to work with Python. It is also great for prototyping an application before moving to a larger database such as MySQL or Postgres. For more on how to choose the right database system read our <a href="https://www.digitalocean.com/community/tutorials/sqlite-vs-mysql-vs-postgresql-a-comparison-of-relational-database-management-systems">SQLite vs MySQL vs PostgreSQL: A Comparison Of Relational Database Management Systems</a> article.</p>

<h2 id="prerequisites">Prerequisites</h2>

<p>Before you start following this guide, you will need:</p>

<ul>
<li>A local Python 3 programming environment, follow the tutorial for your distribution in <a href="https://www.digitalocean.com/community/tutorial_series/how-to-install-and-set-up-a-local-programming-environment-for-python-3">How To Install and Set Up a Local Programming Environment for Python 3</a> series for your local machine. In this tutorial we’ll call our project directory <code>flask_todo</code>.</li>
<li>An understanding of basic Flask concepts such as creating routes, rendering HTML templates, and connecting to an SQLite database. You can follow <a href="https://www.digitalocean.com/community/tutorials/how-to-make-a-web-application-using-flask-in-python-3">How To Make a Web Application Using Flask in Python 3</a>, if you are not familiar with these concepts, but it&rsquo;s not necessary.</li>
</ul>

<h2 id="step-1-—-creating-the-database">Step 1 — Creating the Database</h2>

<p>In this step, you will activate your programming environment, install Flask, create the SQLite database, and populate it with sample data. You&rsquo;ll learn how to use foreign keys to create a one-to-many relationship between lists and items. A <em>foreign key</em> is a key used to associate a database table with another table, it is the link between the child table and its parent table.</p>

<p>If you haven’t already activated your programming environment, make sure you’re in your project directory (<code><span class="highlight">flask_todo</span></code>) and use this command to activate it:</p>
<pre class="code-pre command prefixed"><code><ul class="prefixed"><li class="line" prefix="$">source <span class="highlight">env</span>/bin/activate
</li></ul></code></pre>
<p>Once your programming environment is activated, install Flask using the following command:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">pip install flask
</li></ul></code></pre>
<p>Once the installation is complete, you can now create the database schema file that contains SQL commands to create the tables you need to store your to-do data. You will need two tables: a table called <code>lists</code> to store to-do lists, and an <code>items</code> table to store the items of each list.</p>

<p>Open a file called <code>schema.sql</code> inside your <code><span class="highlight">flask_todo</span></code> directory:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">nano schema.sql
</li></ul></code></pre>
<p>Type the following SQL commands inside this file:</p>
<div class="code-label " title="flask_todo/schema.sql">flask_todo/schema.sql</div><pre class="code-pre "><code class="code-highlight language-sql">DROP TABLE IF EXISTS lists;
DROP TABLE IF EXISTS items;

CREATE TABLE lists (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    title TEXT NOT NULL
);

CREATE TABLE items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    list_id INTEGER NOT NULL,
    created TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    content TEXT NOT NULL,
    FOREIGN KEY (list_id) REFERENCES lists (id)
);
</code></pre>
<p>Save and close the file.</p>

<p>The first two SQL command are <code>DROP TABLE IF EXISTS lists;</code> and <code>DROP TABLE IF EXISTS items;</code>, these delete any already existing tables named <code>lists</code> and <code>items</code> so you don&rsquo;t see confusing behavior. Note that this will delete all of the content you have in the database whenever you use these SQL commands, so ensure you don&rsquo;t write any important content in the web application until you finish this tutorial and experiment with the final result.</p>

<p>Next, you use <code>CREATE TABLE lists</code> to create the <code>lists</code> table that will store the to-do lists (such as a study list, work list, home list, and so on) with the following columns:</p>

<ul>
<li><code>id</code>: An integer that represents a <em>primary key</em>, this will get assigned a unique value by the database for each entry (i.e. to-do list).</li>
<li><code>created</code>: The time the to-do list was created at. <code>NOT NULL</code> signifies that this column should not be empty and the <code>DEFAULT</code> value is the <code>CURRENT_TIMESTAMP</code> value, which is the time at which the list was added to the database. Just like <code>id</code>, you don&rsquo;t need to specify a value for this column, as it will be automatically filled in.</li>
<li><code>title</code>: The list title.</li>
</ul>

<p>Then, you create a table called <code>items</code> to store to-do items. This table has an ID, a <code>list_id</code> integer column to identify which list an item belongs to, a creation date, and the item&rsquo;s content. To link an item to a list in the database you use a <em>foreign key constraint</em> with the line <code>FOREIGN KEY (list_id) REFERENCES lists (id)</code>. Here the <code>lists</code> table is a <em>parent table</em>, which is the table that is being referenced by the foreign key constraint, this indicates a list can have multiple items. The <code>items</code> table is a <em>child table</em>, which is the table the constraint applies to. This means items belong to a single list. The <code>list_id</code> column references the <code>id</code> column of the <code>lists</code> parent table.</p>

<p>Since a list can have <strong>many</strong> items, and an item belongs to only <strong>one</strong> list, the relationship between the <code>lists</code> and <code>items</code> tables is a <em>one-to-many</em> relationship.</p>

<p>Next, you will use the <code>schema.sql</code> file to create the database. Open a file named <code>init_db.py</code> inside the <code><span class="highlight">flask_todo</span></code> directory:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">nano init_db.py
</li></ul></code></pre>
<p>Then add the following code:</p>
<div class="code-label " title="flask_todo/init_db.py">flask_todo/init_db.py</div><pre class="code-pre "><code class="code-highlight language-python">import sqlite3

connection = sqlite3.connect('database.db')


with open('schema.sql') as f:
    connection.executescript(f.read())

cur = connection.cursor()

cur.execute("INSERT INTO lists (title) VALUES (?)", ('Work',))
cur.execute("INSERT INTO lists (title) VALUES (?)", ('Home',))
cur.execute("INSERT INTO lists (title) VALUES (?)", ('Study',))

cur.execute("INSERT INTO items (list_id, content) VALUES (?, ?)",
            (1, 'Morning meeting')
            )

cur.execute("INSERT INTO items (list_id, content) VALUES (?, ?)",
            (2, 'Buy fruit')
            )

cur.execute("INSERT INTO items (list_id, content) VALUES (?, ?)",
            (2, 'Cook dinner')
            )

cur.execute("INSERT INTO items (list_id, content) VALUES (?, ?)",
            (3, 'Learn Flask')
            )

cur.execute("INSERT INTO items (list_id, content) VALUES (?, ?)",
            (3, 'Learn SQLite')
            )

connection.commit()
connection.close()
</code></pre>
<p>Save and close the file.</p>

<p>Here you connect to a file called <code>database.db</code> that will be created once you execute this program. You then open the <code>schema.sql</code> file and run it using the <a href="https://docs.python.org/3/library/sqlite3.html#sqlite3.Connection.executescript"><code>executescript()</code></a> method that executes multiple SQL statements at once.</p>

<p>Running <code>schema.sql</code> will create the <code>lists</code> and <code>items</code> tables. Next, using a <a href="https://docs.python.org/3/library/sqlite3.html#cursor-objects">Cursor object</a>, you execute a few <code>INSERT</code> SQL statements to create three lists and five to-do items.</p>

<p>You use the <code>list_id</code> column to link each item to a list via the list&rsquo;s <code>id</code> value. For example, the <code>Work</code> list was the first insertion into the database, so it will have the ID <code>1</code>. This is how you can link the <code>Morning meeting</code> to-do item to <code>Work</code>—the same rule applies to the other lists and items.</p>

<p>Finally, you commit the changes and close the connection.</p>

<p>Run the program:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">python init_db.py
</li></ul></code></pre>
<p>After execution, a new file called <code>database.db</code> will appear in your <code>flask_todo</code> directory.</p>

<p>You&rsquo;ve activated your environment, installed Flask, and created the SQLite database. Next, you&rsquo;ll retrieve the lists and items from the database and display them in the application&rsquo;s homepage.</p>

<h2 id="step-2-—-displaying-to-do-items">Step 2 — Displaying To-do Items</h2>

<p>In this step, you will connect the database you created in the previous step to a Flask application that displays the to-do lists and the items of each list. You will learn how to use SQLite joins to query data from two tables and how to group to-do items by their lists.</p>

<p>First, you will create the application file. Open a file named <code>app.py</code> inside the <code>flask_todo</code> directory:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">nano app.py
</li></ul></code></pre>
<p>And then add the following code to the file:</p>
<div class="code-label " title="flask_todo/app.py">flask_todo/app.py</div><pre class="code-pre "><code class="code-highlight language-python">from itertools import groupby
import sqlite3
from flask import Flask, render_template, request, flash, redirect, url_for


def get_db_connection():
    conn = sqlite3.connect('database.db')
    conn.row_factory = sqlite3.Row
    return conn


app = Flask(__name__)
app.config['SECRET_KEY'] = 'this should be a secret random string'


@app.route('/')
def index():
    conn = get_db_connection()
    todos = conn.execute('SELECT i.content, l.title FROM items i JOIN lists l \
                          ON i.list_id = l.id ORDER BY l.title;').fetchall()

    lists = {}

    for k, g in groupby(todos, key=lambda t: t['title']):
        lists[k] = list(g)

    conn.close()
    return render_template('index.html', lists=lists)
</code></pre>
<p>Save and close the file.</p>

<p>The <code>get_db_connection()</code> function opens a connection to the <code>database.db</code> database file and then sets the <a href="https://docs.python.org/3/library/sqlite3.html#sqlite3.Connection.row_factory"><code>row_factory</code></a> attribute to <code>sqlite3.Row</code>. In this way you can have name-based access to columns; this means that the database connection will return rows that behave like regular Python dictionaries. Lastly, the function returns the <code>conn</code> connection object you&rsquo;ll be using to access the database.</p>

<p>In the <code>index()</code> view function, you open a database connection and execute the following SQL query:</p>
<pre class="code-pre "><code class="code-highlight language-sql">SELECT i.content, l.title FROM items i JOIN lists l ON i.list_id = l.id ORDER BY l.title;
</code></pre>
<p>You then retrieve its results by using the <code>fetchall()</code> method and save the data in a variable called <code>todos</code>.</p>

<p>In this query, you use <code>SELECT</code> to get the content of the item and the title of the list it belongs to by joining both the <code>items</code> and <code>lists</code> tables (with the table aliases <code>i</code> for <code>items</code> and <code>l</code> for <code>lists</code>). With the join condition <code>i.list_id = l.id</code> after the <code>ON</code> keyword, you will get each row from the <code>items</code> table with every row from the <code>lists</code> table where the <code>list_id</code> column of the <code>items</code> table matches the <code>id</code> of the <code>lists</code> table. You then use <code>ORDER BY</code> to order the results by list titles.</p>

<p>To understand this query better, open the <a href="https://www.digitalocean.com/community/tutorials/how-to-work-with-the-python-interactive-console">Python REPL</a> in your <code>flask_todo</code> directory:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">python
</li></ul></code></pre>
<p>To understand the SQL query, examine the contents of the <code>todos</code> variable by running this small program:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="&gt;&gt;&gt;">from app import get_db_connection
</li><li class="line" prefix="&gt;&gt;&gt;">conn = get_db_connection()
</li><li class="line" prefix="&gt;&gt;&gt;">todos = conn.execute('SELECT i.content, l.title FROM items i JOIN lists l \
</li><li class="line" prefix="&gt;&gt;&gt;">ON i.list_id = l.id ORDER BY l.title;').fetchall()
</li><li class="line" prefix="&gt;&gt;&gt;">for todo in todos:
</li><li class="line" prefix="&gt;&gt;&gt;">    print(todo['title'], ':', todo['content'])
</li></ul></code></pre>
<p>You first import the <code>get_db_connection</code> from the <code>app.py</code> file then open a connection and execute the query (note that this is the same SQL query you have in your <code>app.py</code> file). In the <code>for</code> loop you print the title of the list and the content of each to-do item.</p>

<p>The output will be as follows:</p>
<pre class="code-pre "><code><div class="secondary-code-label " title="Output">Output</div>Home : Buy fruit
Home : Cook dinner
Study : Learn Flask
Study : Learn SQLite
Work : Morning meeting
</code></pre>
<p>Close the REPL using <code>CTRL + D</code>.</p>

<p>Now that you understand how SQL joins work and what the query achieves, let&rsquo;s return back to the <code>index()</code> view function in your <code>app.py</code> file. After declaring the <code>todos</code> variable, you group the results using the following code:</p>
<pre class="code-pre "><code class="code-highlight language-python">lists = {}

for k, g in groupby(todos, key=lambda t: t['title']):
    lists[k] = list(g)
</code></pre>
<p>You first declare an empty dictionary called <code>lists</code>, then use a <code>for</code> loop to go through a grouping of the results in the <code>todos</code> variable by the list&rsquo;s title. You use the <a href="https://docs.python.org/3.5/library/itertools.html#itertools.groupby"><code>groupby()</code></a> function you imported from the <code>itertools</code> standard library. This function will go through each item in the <code>todos</code> variable and generate a group of results for each key in the <code>for</code> loop.</p>

<p><code>k</code> represents list titles (that is, <code>Home</code>, <code>Study</code>, <code>Work</code>), which are extracted using the function you pass to the <code>key</code> parameter of the <code>groupby()</code> function. In this case the function is <code>lambda t: t['title']</code> that takes a to-do item and returns the title of the list (as you have done before with <code>todo['title']</code> in the previous for loop). <code>g</code> represents the group that contains the to-do items of each list title. For example, in the first iteration, <code>k</code> will be <code>'Home'</code>, while <code>g</code> is an <a href="https://docs.python.org/3/glossary.html#term-iterable">iterable</a> that will contain the items <code>'Buy fruit'</code> and <code>'Cook dinner'</code>.</p>

<p>This gives us a representation of the one-to-many relationship between lists and items, where each list title has several to-do items.</p>

<p>When running the <code>app.py</code> file, and after the <code>for</code> loop finishes execution, <code>lists</code> will be as follows:</p>
<pre class="code-pre "><code><div class="secondary-code-label " title="Output">Output</div>{'Home': [&lt;sqlite3.Row object at 0x7f9f58460950&gt;,
          &lt;sqlite3.Row object at 0x7f9f58460c30&gt;],
 'Study': [&lt;sqlite3.Row object at 0x7f9f58460b70&gt;,
           &lt;sqlite3.Row object at 0x7f9f58460b50&gt;],
 'Work': [&lt;sqlite3.Row object at 0x7f9f58460890&gt;]}
</code></pre>
<p>Each <code>sqlite3.Row</code> object will contain the data you retrieved from the <code>items</code> table using the SQL query in the <code>index()</code> function. To represent this data better, let&rsquo;s make a program that goes through the <code>lists</code> dictionary and displays each list and its items.</p>

<p>Open a file called <code>list_example.py</code> in your <code>flask_todo</code> directory:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">nano list_example.py
</li></ul></code></pre>
<p>Then add the following code:</p>
<div class="code-label " title="flask_todo/list_example.py">flask_todo/list_example.py</div><pre class="code-pre "><code class="code-highlight language-python">
from itertools import groupby
from app import get_db_connection

conn = get_db_connection()
todos = conn.execute('SELECT i.content, l.title FROM items i JOIN lists l \
                        ON i.list_id = l.id ORDER BY l.title;').fetchall()

lists = {}

for k, g in groupby(todos, key=lambda t: t['title']):
    lists[k] = list(g)

for list_, items in lists.items():
    print(list_)
    for item in items:
        print('    ', item['content'])
</code></pre>
<p>Save and close the file.</p>

<p>This is very similar to the content in your <code>index()</code> view function. The last <code>for</code> loop here illustrates how the <code>lists</code> dictionary is structured. You first go through the dictionary&rsquo;s items, print the list title (which is in the <code>list_</code> variable), then go through each group of to-do items that belong to the list and print the content value of the item.</p>

<p>Run the <code>list_example.py</code> program:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">python list_example.py
</li></ul></code></pre>
<p>Here is the output of <code>list_example.py</code>:</p>
<pre class="code-pre "><code><div class="secondary-code-label " title="Output">Output</div>Home
     Buy fruit
     Cook dinner
Study
     Learn Flask
     Learn SQLite
Work
     Morning meeting
</code></pre>
<p>Now that you understand each part of the <code>index()</code> function, let&rsquo;s create a base template and create the <code>index.html</code> file you rendered using the line <code>return render_template('index.html', lists=lists)</code>.</p>

<p>In your <code>flask_todo</code> directory, create a <code>templates</code> directory and open a file called <code>base.html</code> inside it:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">mkdir templates
</li><li class="line" prefix="(env)sammy@localhost:$">nano templates/base.html
</li></ul></code></pre>
<p>Add the following code inside <code>base.html</code>, note that you&rsquo;re using <a href="https://getbootstrap.com/">Bootstrap</a> here. If you are not familiar with HTML templates in Flask, see <a href="https://www.digitalocean.com/community/tutorials/how-to-make-a-web-application-using-flask-in-python-3#step-3-%E2%80%94-using-html-templates">Step 3 of How To Make a Web Application Using Flask in Python 3</a>:</p>
<div class="code-label " title="flask_todo/templates/base.html">flask_todo/templates/base.html</div><pre class="code-pre "><code class="code-highlight language-html">&lt;!doctype html&gt;
&lt;html lang="en"&gt;
  &lt;head&gt;
    &lt;!-- Required meta tags --&gt;
    &lt;meta charset="utf-8"&gt;
    &lt;meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no"&gt;

    &lt;!-- Bootstrap CSS --&gt;
    &lt;link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" crossorigin="anonymous"&gt;

    &lt;title&gt;{ block title } { endblock }&lt;/title&gt;
  &lt;/head&gt;
  &lt;body&gt;
    &lt;nav class="navbar navbar-expand-md navbar-light bg-light"&gt;
        &lt;a class="navbar-brand" href="{{ url_for('index')}}"&gt;FlaskTodo&lt;/a&gt;
        &lt;button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation"&gt;
            &lt;span class="navbar-toggler-icon"&gt;&lt;/span&gt;
        &lt;/button&gt;
        &lt;div class="collapse navbar-collapse" id="navbarNav"&gt;
            &lt;ul class="navbar-nav"&gt;
            &lt;li class="nav-item active"&gt;
                &lt;a class="nav-link" href="#"&gt;About&lt;/a&gt;
            &lt;/li&gt;
            &lt;/ul&gt;
        &lt;/div&gt;
    &lt;/nav&gt;
    &lt;div class="container"&gt;
        { block content } { endblock }
    &lt;/div&gt;

    &lt;!-- Optional JavaScript --&gt;
    &lt;!-- jQuery first, then Popper.js, then Bootstrap JS --&gt;
    &lt;script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"&gt;&lt;/script&gt;
    &lt;script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"&gt;&lt;/script&gt;
    &lt;script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"&gt;&lt;/script&gt;
  &lt;/body&gt;
&lt;/html&gt;
</code></pre>
<p>Save and close the file.</p>

<p>Most of the code in the preceding block is standard HTML and code required for Bootstrap. The <code>&lt;meta&gt;</code> tags provide information for the web browser, the <code>&lt;link&gt;</code> tag links the Bootstrap CSS files, and the <code>&lt;script&gt;</code> tags are links to JavaScript code that allows some additional Bootstrap features. Check out the <a href="https://getbootstrap.com/">Bootstrap documentation</a> for more information.</p>

<p>Next, create the <code>index.html</code> file that will extend this <code>base.html</code> file:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">nano templates/index.html
</li></ul></code></pre>
<p>Add the following code to <code>index.html</code>:</p>
<div class="code-label " title="flask_todo/templates/index.html">flask_todo/templates/index.html</div><pre class="code-pre "><code class="code-highlight language-html">{ extends 'base.html' }

{ block content }
    &lt;h1&gt;{ block title } Welcome to FlaskTodo { endblock }&lt;/h1&gt;
    { for list, items in lists.items() }
        &lt;div class="card" style="width: 18rem; margin-bottom: 50px;"&gt;
            &lt;div class="card-header"&gt;
                &lt;h3&gt;{{ list }}&lt;/h3&gt;
            &lt;/div&gt;
            &lt;ul class="list-group list-group-flush"&gt;
                { for item in items }
                    &lt;li class="list-group-item"&gt;{{ item['content'] }}&lt;/li&gt;
                { endfor }
            &lt;/ul&gt;
        &lt;/div&gt;
    { endfor }
{ endblock }
</code></pre>
<p>Here you use a <code>for</code> loop to go through each item of the <code>lists</code> dictionary, you display the list title as a card header inside an <code>&lt;h3&gt;</code> tag, and then use a list group to display each to-do item that belongs to the list in an <code>&lt;li&gt;</code> tag. This follows the same rules explained in the <code>list_example.py</code> program.</p>

<p>You will now set the environment variables Flask needs and run the application using the following commands:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">export FLASK_APP=app
</li><li class="line" prefix="(env)sammy@localhost:$">export FLASK_ENV=development
</li><li class="line" prefix="(env)sammy@localhost:$">flask run
</li></ul></code></pre>
<p>Once the development server is running, you can visit the URL <code>http://127.0.0.1:5000/</code> in your browser. You will see a web page with the &ldquo;Welcome to FlaskTodo&rdquo; and your list items.</p>

<p><img src="https://assets.digitalocean.com/articles/flask_sqlite/image_welcome.png" alt="Home Page"></p>

<p>You can now type <code>CTRL + C</code> to stop your development server.</p>

<p>You&rsquo;ve created a Flask application that displays the to-do lists and the items of each list. In the next step, you will add a new page for creating new to-do items.</p>

<h2 id="step-3-—-adding-new-to-do-items">Step 3 — Adding New To-do Items</h2>

<p>In this step, you will make a new route for creating to-do items, you will insert data into database tables, and associate items with the lists they belong to.</p>

<p>First, open the <code>app.py</code> file:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">nano app.py
</li></ul></code></pre>
<p>Then, add a new <code>/create</code> route with a view function called <code>create()</code> at the end of the file:</p>
<div class="code-label " title="flask_todo/app.py">flask_todo/app.py</div><pre class="code-pre "><code class="code-highlight language-python">...
<span class="highlight">@app.route('/create/', methods=('GET', 'POST'))</span>
<span class="highlight">def create():</span>
<span class="highlight">    conn = get_db_connection()</span>
<span class="highlight">    lists = conn.execute('SELECT title FROM lists;').fetchall()</span>
<span class="highlight"></span>
<span class="highlight">    conn.close()</span>
<span class="highlight">    return render_template('create.html', lists=lists)</span>
</code></pre>
<p>Save and close the file.</p>

<p>Because you will use this route to insert new data to the database via a web form, you allow both GET and POST requests using <code>methods=('GET', 'POST')</code> in the <code>app.route()</code> decorator. In the <code>create()</code> view function, you open a database connection then get all the list titles available in the database, close the connection, and render a <code>create.html</code> template passing it the list titles.</p>

<p>Next, open a new template file called <code>create.html</code>:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">nano templates/create.html
</li></ul></code></pre>
<p>Add the following HTML code to <code>create.html</code>:</p>
<div class="code-label " title="flask_todo/templates/create.html">flask_todo/templates/create.html</div><pre class="code-pre "><code class="code-highlight language-html">{ extends 'base.html' }

{ block content }
&lt;h1&gt;{ block title } Create a New Item { endblock }&lt;/h1&gt;

&lt;form method="post"&gt;
    &lt;div class="form-group"&gt;
        &lt;label for="content"&gt;Content&lt;/label&gt;
        &lt;input type="text" name="content"
               placeholder="Todo content" class="form-control"
               value="{{ request.form['content'] }}"&gt;&lt;/input&gt;
    &lt;/div&gt;

    &lt;div class="form-group"&gt;
        &lt;label for="list"&gt;List&lt;/label&gt;
        &lt;select class="form-control" name="list"&gt;
            { for list in lists }
                { if list['title'] == request.form['list'] }
                    &lt;option value="{{ request.form['list'] }}" selected&gt;
                        {{ request.form['list'] }}
                    &lt;/option&gt;
                { else }
                    &lt;option value="{{ list['title'] }}"&gt;
                        {{ list['title'] }}
                    &lt;/option&gt;
                { endif }
            { endfor }
        &lt;/select&gt;
    &lt;/div&gt;
    &lt;div class="form-group"&gt;
        &lt;button type="submit" class="btn btn-primary"&gt;Submit&lt;/button&gt;
    &lt;/div&gt;
&lt;/form&gt;
{ endblock }
</code></pre>
<p>Save and close the file.</p>

<p>You use <code>request.form</code> to access the form data that is stored in case something goes wrong with your form submission (for example, if no to-do content was provided). In the <code>&lt;select&gt;</code> element, you loop through the lists you retrieved from the database in the <code>create()</code> function. If the list title is equal to what is stored in <code>request.form</code> then the selected option is that list title, otherwise, you display the list title in a normal non-selected <code>&lt;option&gt;</code> tag.</p>

<p>Now, in the terminal, run your Flask application:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">flask run
</li></ul></code></pre>
<p>Then visit <code>http://127.0.0.1:5000/create</code> in your browser, you will see a form for creating a new to-do item, note that the form doesn&rsquo;t work yet because you have no code to handle POST requests that get sent by the browser when submitting the form.</p>

<p>Type <code>CTRL + C</code> to stop your development server.</p>

<p>Next, let&rsquo;s add the code for handling POST requests to the <code>create()</code> function and make the form function properly, open <code>app.py</code>:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">nano app.py
</li></ul></code></pre>
<p>Then edit the <code>create()</code> function to look like so:</p>
<div class="code-label " title="flask_todo/app.py">flask_todo/app.py</div><pre class="code-pre "><code class="code-highlight language-python">...
<a href="https://www.digitalocean.com/community/users/app-route" class="username-tag">@app.route</a>('/create/', methods=('GET', 'POST'))
def create():
    conn = get_db_connection()

    <span class="highlight">if request.method == 'POST':</span>
    <span class="highlight">    content = request.form['content']</span>
    <span class="highlight">    list_title = request.form['list']</span>

    <span class="highlight">    if not content:</span>
    <span class="highlight">        flash('Content is required!')</span>
    <span class="highlight">        return redirect(url_for('index'))</span>

    <span class="highlight">    list_id = conn.execute('SELECT id FROM lists WHERE title = (?);',</span>
    <span class="highlight">                             (list_title,)).fetchone()['id']</span>
    <span class="highlight">    conn.execute('INSERT INTO items (content, list_id) VALUES (?, ?)',</span>
    <span class="highlight">                 (content, list_id))</span>
    <span class="highlight">    conn.commit()</span>
    <span class="highlight">    conn.close()</span>
    <span class="highlight">    return redirect(url_for('index'))</span>

    lists = conn.execute('SELECT title FROM lists;').fetchall()

    conn.close()
    return render_template('create.html', lists=lists)
</code></pre>
<p>Save and close the file.</p>

<p>Inside the <code>request.method == 'POST'</code> condition you get the to-do item&rsquo;s content and the list&rsquo;s title from the form data. If no content was submitted, you send the user a message using the <code>flash()</code> function and redirect to the index page. If this condition was not triggered, then you execute a <code>SELECT</code> statement to get the list ID from the provided list title and save it in a variable called <code>list_id</code>. You then execute an <code>INSERT INTO</code> statement to insert the new to-do item into the <code>items</code> table. You use the <code>list_id</code> variable to link the item to the list it belongs to. Finally, you commit the transaction, close the connection, and redirect to the index page.</p>

<p>As a last step, you will add a link to <code>/create</code> in the navigation bar and display flashed messages below it, to do this, open <code>base.html</code>:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">nano templates/base.html
</li></ul></code></pre>
<p>Edit the file by adding a new <code>&lt;li&gt;</code> navigation item that links to the <code>create()</code> view function. Then display the flashed messages using a <code>for</code> loop above the <code>content</code> block. These are available in the <a href="https://flask.palletsprojects.com/en/1.1.x/patterns/flashing/"><code>get_flashed_messages()</code> Flask function</a>:</p>
<div class="code-label " title="flask_todo/templates/base.html">flask_todo/templates/base.html</div><pre class="code-pre "><code class="code-highlight language-html">&lt;nav class="navbar navbar-expand-md navbar-light bg-light"&gt;
    &lt;a class="navbar-brand" href="{{ url_for('index')}}"&gt;FlaskTodo&lt;/a&gt;
    &lt;button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation"&gt;
        &lt;span class="navbar-toggler-icon"&gt;&lt;/span&gt;
    &lt;/button&gt;
    &lt;div class="collapse navbar-collapse" id="navbarNav"&gt;
        &lt;ul class="navbar-nav"&gt;
        <span class="highlight">&lt;li class="nav-item active"&gt;</span>
        <span class="highlight">    &lt;a class="nav-link" href="{{ url_for('create') }}"&gt;New&lt;/a&gt;</span>
        <span class="highlight">&lt;/li&gt;</span>

        &lt;li class="nav-item active"&gt;
            &lt;a class="nav-link" href="#"&gt;About&lt;/a&gt;
        &lt;/li&gt;
        &lt;/ul&gt;
    &lt;/div&gt;
&lt;/nav&gt;
&lt;div class="container"&gt;
    <span class="highlight">{ for message in get_flashed_messages() }</span>
    <span class="highlight">    &lt;div class="alert alert-danger"&gt;{{ message }}&lt;/div&gt;</span>
    <span class="highlight">{ endfor }</span>
    {block content } { endblock }
&lt;/div&gt;
</code></pre>
<p>Save and close the file.</p>

<p>Now, in the terminal, run your Flask application:</p>
<pre class="code-pre custom_prefix prefixed"><code><ul class="prefixed"><li class="line" prefix="(env)sammy@localhost:$">flask run
</li></ul></code></pre>
<p>A new link to <code>/create</code> will appear in the navigation bar. If you navigate to this page and try to add a new to-do item with no content, you&rsquo;ll receive a flashed message saying <strong>Content is required!</strong>. If you fill in the content form, a new to-do item will appear on the index page.</p>

<p>In this step, you have added the ability to create new to-do items and save them to the database.</p>

<p>You can find the source code for this project in <a href="https://github.com/do-community/flask-todo">this repository</a>.</p>

<h2 id="conclusion">Conclusion</h2>

<p>You now have an application to manage to-do lists and items. Each list has several to-do items and each to-do item belongs to a single list in a one-to-many relationship. You learned how to use Flask and SQLite to manage multiple related database tables, how to use <em>foreign keys</em> and how to retrieve and display related data from two tables in a web application using SQLite joins.</p>

<p>Furthermore, you grouped results using the <code>groupby()</code> function, inserted new data to the database, and associated database table rows with the tables they are related to. You can learn more about foreign keys and database relationships from the <a href="https://www.sqlite.org/foreignkeys.html">SQLite documentation</a>.</p>

<p>You can also read more of our <a href="https://www.digitalocean.com/community/tags/python-frameworks">Python Framework content</a>. If you want to check out the <code>sqlite3</code> Python module, read our tutorial on <a href="https://www.digitalocean.com/community/tutorials/how-to-use-the-sqlite3-module-in-python-3">How To Use the sqlite3 Module in Python 3</a>.</p>