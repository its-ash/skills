@REF:tinystruct-patterns
# tinystruct v1.7.37 | CLI+HTTP dual-mode Java framework | ¬main() | minimal cfg

§CORE{
  principle:CLI⇔HTTP_equal_citizens;
  @Action(mode=Mode.DEFAULT|omitted)⇒transport_neutral(CLI∧HTTP);
  ¬cli_compat_if(HTTP_deps(Request,Response,session,uploads));
  Request|Response∈HTTP_ctx_attrs⇒null_in_CLI⇒isolate_shared_logic;
  transport_bound(Mode.CLI|Mode.HTTP_*)⇒other_transport_rejects("The action is not allowed to be executed.");
  lifecycle:extend AbstractApplication→init()(setup,setTemplateRequired(false) if API)∧version()∧getContext()∧getConfiguration(k);
  routing:ActionRegistry(auto path→params,injects Request/Response from Context,first_match_wins);
  json:org.tinystruct.data.component.{Builder,Builders}(¬Gson,¬Jackson,¬List<Builder>);
  async_events:CompletableFuture.runAsync() inside event handler;
  flags:getContext().getAttribute("--flag") for optional CLI flags;
  modularity:granular AbstractApplication subclasses;¬setAction(),use @Action
}

§CMD[dispatcher]{
  priority:bin/dispatcher(default dev/run/test/debug for DEFAULT|Mode.CLI before IDE/main/curl/browser);
  http_only(Mode.HTTP_*):skip CLI→start server∧test over HTTP;
  ¬main(String[] args);
  run:bin/dispatcher greet/James --import com.example.MyService;
  flag:bin/dispatcher echo --words "Praise the Lord";
  srv:bin/dispatcher start --import org.tinystruct.system.HttpServer [--import com.example.MyService];
  info:bin/dispatcher --help|--version;
  import_rule:1_class_per_--import(--import a.A --import b.B; ¬"--import a.A,b.B"→ClassNotFoundException)∨application.properties:default.import.applications=a.A;b.B(";"-sep)
}

§CMD[launcher_gen]{
  rule:framework_generates_bin/_never_handwrite_or_copy;
  trigger:ApplicationManager.init()|ApplicationManager.install(app,cfg) creates missing OS script in CWD from jar template;
  steps:{
    1:read <tinystruct.version>|org.tinystruct:tinystruct in pom.xml;ensure jar∈~/.m2/repository/org/tinystruct/tinystruct/<ver>/(mvn dependency:resolve)∨lib/;
    2:from_root:
      Unix:java -cp ~/.m2/repository/org/tinystruct/tinystruct/<ver>/tinystruct-<ver>.jar org.tinystruct.system.Dispatcher --version → bin/dispatcher(exec,LF);
      Win:java -cp %USERPROFILE%\.m2\repository\org\tinystruct\tinystruct\<ver>\tinystruct-<ver>.jar org.tinystruct.system.Dispatcher --version → bin\dispatcher.cmd(CRLF);
    3:verify:bin/dispatcher --version → "Dispatcher (cli) (built on tinystruct-<ver>)"∧VERSION==jar_ver∧--help lists actions;
    4:both_OS:run step2 on each OS(CI/teammate)∧commit;¬"-Dos.name=…" on Win(UnsupportedOperationException in setPosixFilePermissions→empty bin/dispatcher)
  };
  upgrade:bump pom.xml→rm old script→step2 ⊕ bin/dispatcher update(Maven Central latest,edits pom.xml,force-regen,needs_net);
  surefire_fix:tests calling init()/install() scatter bin/dispatcher.cmd→pom.xml surefire <workingDirectory>${project.build.directory}</workingDirectory>;
  internals:{
    root:bin/dispatcher=CWD, .cmd=parent(bin/);
    cp:target/classes, lib/*.jar, WEB-INF/lib/*, WEB-INF/classes, tinystruct_jar(lib/ else ~/.m2)→org.tinystruct.system.Dispatcher;
    first_run:extracts mvnw/mvnw.cmd if missing(unzip Unix / PowerShell Win);
    jvm_opts:-D…/-X… supported in shell script only
  };
  gotchas:{
    win_git_bash:":" CP fails w/ ClassNotFoundException: org.tinystruct.system.Dispatcher→use bin\dispatcher.cmd(requires JAVA_HOME)∨WSL;
    deps:no fat jar→mvn dependency:copy-dependencies -DoutputDirectory=lib (JDBC drivers,jjwt,lettuce,sibling jars; gitignore lib/; missing→NoClassDefFoundError);
    layout:bin/ directly under dir holding target/classes∧lib/
  };
  gitattributes:"bin/dispatcher text eol=lf\nbin/dispatcher.cmd text eol=crlf"
}

§PAT[app_examples]{
```java
public class MyService extends AbstractApplication {
  @Override public void init() { this.setTemplateRequired(false); }
  @Override public String version() { return "1.0.0"; }
  @Action("greet") public String greet() { return "Hello from tinystruct!"; }
  @Action("greet") public String greet(String name) { return "Hello, " + name + "!"; } // CLI: bin/dispatcher greet/James | HTTP: /?q=greet/James
}
```
  login_auth:```java
@Action(value = "login", mode = Mode.HTTP_POST)
public String doLogin(Request<?, ?> req) throws ApplicationException {
  String u = req.getParameter("username"), p = req.getParameter("password"); // do NOT trim/mutate
  if (u == null || p == null || u.length() > 256 || p.length() > 1024 || u.isBlank() || p.isBlank()) // example UTF-16 limits
    throw new ApplicationException("Invalid credentials");
  String uid = AuthService.getInstance().authenticate(u, p); // app-owned, null on fail
  if (uid == null) throw new ApplicationException("Invalid credentials");
  req.getSession().setAttribute("userId", uid); // touch session ONLY post-auth
  return "Logged in";
}
```
  json:```java
Builders list = new Builders();
Builder item = new Builder(); item.put("id", 1); item.put("name", "James"); list.add(item);
Builder res = new Builder(); res.put("status", "success"); res.put("data", list);
return res.toString(); // {"status":"success","data":[{"id":1,"name":"James"}]}
```
  sse:```java
@Action("sse/connect") public String connect() { return "{\"type\":\"connect\",\"message\":\"Connected to SSE\"}"; }
SSEPushManager.getInstance().push(getContext().getId(), msg); // msg:Builder
SSEPushManager.getInstance().broadcast(msg);
```
  upload:```java
@Action(value = "upload", mode = Mode.HTTP_POST)
public String upload(Request<?, ?> req) throws ApplicationException {
  List<FileEntity> files = req.getAttachments(); // org.tinystruct.data.FileEntity; file.getFilename()
  return "Upload OK";
}
```
  db_meta:```java
DatabaseOperator op = new DatabaseOperator(); // org.tinystruct.data.DatabaseOperator
try { op.getCatalog(); op.getSchema(); java.sql.DatabaseMetaData md = op.getMetaData(); }
finally { op.close(); }
```
  outbound_http:URLRequest∧HTTPHandler
}

§MCP{
  since:1.7.0(core dep org.tinystruct:tinystruct:1.7.37);
  pkg:org.tinystruct.mcp.{MCPTool,MCPServer,MCPException};
  sec_prompt_inj:tool returns enter model context→∀caller_args validate(nullity,length,charset) before embedding in return string;
  tool_rules:extend MCPTool; @Action(value,description,arguments={@Argument(key,description,type,optional)}); bind params explicitly in method sig(¬getContext().getAttribute);
```java
public class MyCustomTool extends MCPTool {
  public MyCustomTool() { super("custom", "A custom tool for demonstrating MCP"); }
  @Action(value = "custom/hello", description = "Say hello to someone",
    arguments = { @Argument(key = "name", description = "The name to greet", type = "string", optional = false) })
  public String hello(String name) throws MCPException {
    if (name == null || name.length() > 50 || !name.matches("^[a-zA-Z0-9 ]+$")) throw new MCPException("Invalid name provided");
    return "Hello, " + name + "!";
  }
}
public class MyMCPServer extends MCPServer {
  @Override public void init() { super.init(); this.registerTool(new MyCustomTool()); }
  @Override public String version() { return "1.0.0"; }
}
```
  run:bin/dispatcher start --import org.tinystruct.system.HttpServer --import com.example.MyMCPServer;
  overloads:{
    schema_merge:properties=union(overloads), required=intersection(overloads);
    routing:sequential schema validation→first valid overload executes→else throws
  }
}

§CFG[src/main/resources/application.properties]{
```properties
driver=org.h2.Driver
database.url=jdbc:h2:~/mydb
database.user=sa
database.password=
# database.autocreate=true
default.home.page=hello
server.port=8080
default.server.open_browser=true
# server.static.dirs=static,public
default.language=en_US
# default.session.repository=org.tinystruct.http.RedisSessionRepository
# redis.host=127.0.0.1
# redis.port=6379
logging.enabled=true
logging.level=INFO
org.tinystruct.level=FINE
handlers=java.util.logging.ConsoleHandler
# handlers=java.util.logging.ConsoleHandler, java.util.logging.FileHandler
# java.util.logging.FileHandler.{pattern=logs/tinystruct-%g.log,limit=10485760,count=5,level=INFO,formatter=org.tinystruct.system.logging.LogFormatter,encoding=UTF-8}
```
  read:this.getConfiguration("server.port")
}

§LOG{
  impl:JUL wrapper; read once on ApplicationManager init(restart required on change);
  colors(console_only,¬files):SEVERE=red, WARNING=yellow, INFO=green, CONFIG=cyan, FINE=grey;
  caller_trace:StackWalker(class,method,file,line; skips internal layers);
  switch_lvl:logging.enabled=false disables; logging.level∈{OFF,SEVERE|ERROR,WARNING|WARN,INFO,CONFIG,FINE|DEBUG,FINER,FINEST|TRACE,ALL}(def:INFO); pkg override:<pkg>.level=FINE;
  handlers:comma/ws-sep(def:java.util.logging.ConsoleHandler); <handler>.{level(def:ALL),formatter,encoding}; public no-arg ctor req; unknown formatter→LogFormatter; bad handler→stderr(others start);
  file_handler(opt-in):pattern(def:%h/java%u.log; rel→launch_dir; mkdir parent), limit(def:0=unlim), count(def:1; %g=0..count-1), append(def:true);
  gate:pass(logger.level)∧pass(handler.level)
}

§SEC[static_files]{
  roots:server.static.dirs(","|";"-sep) else server.static.dir(def:static);
  v1.7.37_behavior:checks normalized path names BEFORE symlink resolution(rejects .|.., allows sibling dirs outside CWD, symlinked root→project/ancestor bypasses check ∧ serves before isProjectRootFile);
  req_rejects:"."|".." segments, hidden(".git",".env"), trailing "."|" ";
  rule:real dedicated dir(e.g. static/)∧¬symlinked root/parent components; verify containment;
  ref:https://github.com/tinystruct/tinystruct/blob/089ec19022f3bb5d87f1e83e30b2034b24f7e77f/src/main/java/org/tinystruct/system/HttpServer.java#L569-L720
}

§ANTI{
  Gson|Jackson ⇒ Builder|Builders;
  List<Builder> ⇒ Builders;
  "ApplicationRuntimeException: template not found" ⇒ setTemplateRequired(false) in init();
  private @Action ⇒ public @Action;
  main()|skip_bin/dispatcher ⇒ use bin/dispatcher for DEFAULT/CLI, HTTP for HTTP_MODE;
  handwritten|copied bin/dispatcher ⇒ Dispatcher --version from root;
  GitBash/MSYS ClassNotFoundException ⇒ bin\dispatcher.cmd(JAVA_HOME)∨WSL;
  "--import a.A,b.B" ⇒ "--import a.A --import b.B";
  "\r: command not found" ⇒ convert bin/dispatcher CRLF→LF;
  manual ActionRegistry|setAction() ⇒ @Action;
  action_not_found ⇒ --import∨default.import.applications;
  cli_arg_missing ⇒ --key val + getContext().getAttribute("--key");
  same_path_wrong_method ⇒ disambiguate w/ Mode;
  "The action is not allowed to be executed." ⇒ Mode.HTTP_* unreachable via CLI→test HTTP∨split HTTP deps+use Mode.DEFAULT;
  static_404 ⇒ check server.static.dirs|dir, forbidden names, resolved containment, ¬symlinks;
  no_log_file ⇒ add java.util.logging.FileHandler to handlers(+pattern else %h/java%u.log);
  missing_FINE ⇒ set BOTH logging.level|<pkg>.level AND handler .level
}

§RTE[@Action]{
  regex:int→(-?\d+), String→([^/]+) (e.g. ^/?user/(-?\d+)$);
  types:String, int/Integer, long/Long, float/Float, double/Double, boolean/Boolean, char/Character, short/Short, byte/Byte, Date("yyyy-MM-dd HH:mm:ss");
  modes:DEFAULT(CLI+HTTP)|CLI|HTTP_GET|HTTP_POST|HTTP_PUT|HTTP_DELETE|HTTP_PATCH;
  fromName:Action.Mode.fromName(method)→Mode.DEFAULT on null|unknown;
  syntax:@Action(value="path/subpath", description="...", mode=Mode.DEFAULT, example="bin/dispatcher path/subpath/42");
  placeholder:@Action("user/{id}") → CLI:bin/dispatcher user/42 | HTTP:/?q=user/42
}

§DB[AbstractData]{
  pojo:extend AbstractData(getters, setFieldAsXxx setters, setData(Row)); id always `Id`;
  mapping:1_source_per_class(@Table/@Column OR ClassName.map.xml; cached 1x/class; @Table wins over .map.xml);
  xml_loc:mirrors pkg under src/main/resources/; naming:table→singular(users→User), snake→camel(created_at→createdAt);
  crud:append(), appendAndGetId(), update(), delete(), findAll(), findOneById(), findOneByKey(k,v), findWith(where,params), find(sql,params);
  cli_gen:bin/dispatcher generate [--tables users] [--mapping xml|annotation] (def:xml; unknown rejected pre-prompt; uses application.properties w/ ${DB_PASSWORD});
```java
Condition c = new Condition(); c.setRequestFields("id,username");
Table t = user.find(c.select("`users`").and("email LIKE ?").orderBy("id DESC"), new Object[]{"%@example.com"});
```
  xml_fmt:
```xml
<mapping><class name="User" table="users">
  <id name="Id" column="id" autoIncrement="true" autoGenerated="false" length="11" type="int"/>
  <property name="username" column="username" length="50" type="varchar"/>
</class></mapping>
```
  ann(org.tinystruct.data.annotation.{Table,Id,Column}):
```java
@Table(name = "users", id = @Id(name = "Id", column = "id", type = "int", length = 11, autoIncrement = true))
public class User extends AbstractData implements Serializable {
  @Column(name = "username", type = "varchar", length = 50) private String username;
}
```
  ann_rules:{
    @Table:class(name req, schema def="", id def=none; inherited; superclass @Column mapped; dup mapping→error on 1st use);
    @Id:in @Table(name def="Id", column, type, length, autoIncrement[DB], autoGenerated[UUID for non-int]; empty column=no id);
    @Column:field(type req[case-insensitive FieldType:INT,BIGINT,VARCHAR,TEXT,DATE,TIMESTAMP,...], name def=fieldName, length)
  };
  autocreate:database.autocreate=true(def:false; req CREATE priv; 1st instantiation runs CREATE TABLE IF NOT EXISTS / SQLServer OBJECT_ID guard; @Id=PK; TIMESTAMP→DATETIME[MySQL], BLOB→BYTEA[PG], VARCHAR→255; limits:DECIMAL no precision/scale, ¬idx/FK/default/NOT NULL, ¬alter existing→prod:database-design/references/database-migration.md)
}

§TST{
  unit:app=new MyApp(); app.setConfiguration(new Settings()); app.init(); app.invoke("greet", new Object[]{"James"}); ActionRegistry.getInstance().getAction("greet/James");
  http_int:bg thread ApplicationManager.call("start", ctx, Action.Mode.CLI)→poll port(Socket)→URLRequest+HTTPHandler→assert status/body
}

§SRC{
  src/main/java/org/tinystruct/AbstractApplication.java:lifecycle;
  src/main/java/org/tinystruct/system/annotation/Action.java:ann+Modes;
  src/main/java/org/tinystruct/application/ActionRegistry.java:routing;
  src/main/java/org/tinystruct/data/component/{Builder,Builders}.java:JSON_obj/arr;
  src/main/java/org/tinystruct/data/component/AbstractData.java:POJO_CRUD;
  src/main/java/org/tinystruct/data/Mapping.java:cached_metadata;
  src/main/java/org/tinystruct/data/annotation/Table.java:@Table/@Id/@Column;
  src/main/java/org/tinystruct/data/tools/TableCreator.java:autocreate;
  src/main/java/org/tinystruct/data/tools/MySQLGenerator.java:gen(MappingMode);
  src/main/java/org/tinystruct/data/component/FieldType.java:SQL_Java_types;
  src/main/java/org/tinystruct/data/component/Condition.java:fluent_SQL;
  src/main/java/org/tinystruct/http/SSEPushManager.java:SSE;
  src/main/java/org/tinystruct/system/logging/{LogFormatter,LoggerConfigurer}.java:JUL_color+StackWalker;
  src/test/java/org/tinystruct/application/ActionRegistryTest.java:registry_tests;
  src/test/java/org/tinystruct/system/HttpServerHttpModeTest.java:HTTP_int_tests
}
