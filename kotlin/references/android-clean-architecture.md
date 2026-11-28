@REF:android-clean-architecture
§SCOPE{Android∧KMP(AGP_9+,Kotlin_2.4):modules,DI,UseCase/Repo/DS,domain↔data↔pres,Koin_4/Hilt+KSP2,Room_KMP/SQLDelight/Ktor_3}
§MOD{
  dirs:{androidApp/:Android_entry(com.android.application)+MainActivity(enableEdgeToEdge),shared/:KMP_root,core/:utils+base+err,domain/:UseCases+models+repo_ifaces(pure_Kt),data/:repo_impls+DS+DB+net,presentation/:Screens+VMs+UI+nav,design-system/:Compose+theme+type,feature/{auth,settings,profile}/:opt_large};
  deps:{androidApp→{shared,presentation,domain,data,core},presentation→{domain,design-system,core},data→{domain,core},domain→core∨∅,core→∅};
  §R:domain∩{data,presentation,android_fw,fw_ann}≡∅;AGP_9⇒isolate_com.android.application_in_androidApp(¬shared_KMP_module)
}
§PAT{domain:
  UseCase(1_op/cls,`operator fun invoke`):`suspend operator fun invoke(cat:String):Result<List<Item>>`|`operator fun invoke(uid:String):Flow<UserProgress>`;
  Model(plain_Kt,¬fw_ann,KMP_stdlib):`data class`/`enum class(DRAFT,ACTIVE,ARCHIVED)`+`kotlin.time.Instant`+`kotlin.uuid.Uuid`;
  RepoIface(domain→data_impl):`suspend getItemsByCategory(cat):Result<List<Item>>`;`suspend saveItem(item):Result<Unit>`;`observeItems():Flow<List<Item>>`
}
§PAT{data:
  RepoImpl(local,remote):fetch=`runCatching{local.insertItems(remote.fetchItems(cat).map(Dto::toEntity));local.getItemsByCategory(cat).map(Entity::toDomain)}`;save=`runCatching{local.insertItems(listOf(item.toEntity()))}`;observe=`local.observeAll().map{it.map(Entity::toDomain)}`;
  Mapper(ext∈data):`Entity.toDomain()`(`tags.split("|")`,`Status.valueOf(status)`),`Dto.toEntity()`(`tags.joinToString("|")`);
  Room_KMP(Android+iOS+JVM+Wasm@Room_3/`androidx.room:2.8.5`⊕`androidx.room3`+`androidx.sqlite:sqlite-bundled`+KSP2):`@Entity(tableName="items")(@PrimaryKey val id:String,...)`;`@Dao`:`@Query("SELECT * FROM items WHERE category = :category") suspend fun getByCategory(cat:String):List<ItemEntity>`,`@Upsert suspend fun upsert(items:List<ItemEntity>)`,`@Query("SELECT * FROM items") fun observeAll():Flow<List<ItemEntity>>`;
  SQLDelight(SQL-first_KMP,`Item.sq`):`CREATE TABLE ItemEntity(id TEXT NOT NULL PRIMARY KEY,...);getByCategory:SELECT * FROM ItemEntity WHERE category=?;upsert:INSERT OR REPLACE INTO ItemEntity(...) VALUES(...);observeAll:SELECT * FROM ItemEntity;`;
  Ktor_Client(KMP_3.6.x):`client.get("api/items"){parameter("category",cat)}.body<List<ItemDto>>()`, `HttpClient{install(ContentNegotiation){json(Json{ignoreUnknownKeys=true})};install(Logging){level=LogLevel.HEADERS};defaultRequest{url("https://api.example.com/")}}`
}
§PAT{di:
  Koin(KMP_4.2.2,DSL∨Koin_Compiler_Plugin):`factory{UseCase(get())}`(domain);`single<Repo>{RepoImpl(get(),get())};single{LocalDS(get())};single{RemoteDS(get())}`(data);`viewModelOf(::VM)`(pres);
  Hilt(Android_only,KSP2∧¬kapt):`@Module @InstallIn(SingletonComponent::class) abstract class RepoModule{@Binds abstract fun bind(impl:RepoImpl):Repo}`;`@HiltViewModel class VM @Inject constructor(uc:UseCase):ViewModel()`
}
§PAT{err:
  `Result<T>`⊕`sealed interface Try<out T>{data class Success<T>(val value:T):Try<T>;data class Failure(val error:AppError):Try<Nothing>}`;
  `sealed interface AppError{data class Network(val msg:String):AppError;data class Database(val msg:String):AppError;data object Unauthorized:AppError}`;
  VM(Kotlin_2.4_backing_field):`val state:StateFlow<UiState> field = MutableStateFlow(UiState())`;`viewModelScope.launch{state.update{when(r){is Try.Success->it.copy(items=r.value,isLoading=false);is Try.Failure->it.copy(error=r.error.toMessage(),isLoading=false)}}}`
}
§CFG{gradle_conv(AGP_9+Gradle_9):
  `build-logic/src/main/kotlin/kmp-library.gradle.kts`:`plugins{id("org.jetbrains.kotlin.multiplatform");id("com.android.kotlin.multiplatform.library")};kotlin{androidLibrary{namespace="com.example.shared";compileSdk=35;minSdk=24};iosArm64();iosSimulatorArm64();sourceSets{commonMain.dependencies{};commonTest.dependencies{implementation(kotlin("test"))}}}`;
  room_kmp:`plugins{id("androidx.room");id("com.google.devtools.ksp")};room{schemaDirectory("$projectDir/schemas")}`;
  module:`plugins{id("kmp-library")}`
}
§ANTI{¬apply(com.android.library∨com.android.application∈KMP_shared_module@AGP_9);¬deprecated_androidTarget(→androidLibrary{});¬kapt(→KSP2);¬import(Android_fw∈domain);¬expose(Entity∨Dto→UI;map→domain);¬logic∈VM(→UseCase);¬GlobalScope∨unstructured(→viewModelScope∨structured);¬fat_repo(→DataSources);¬circular_deps(A→B⇒¬(B→A))}
§REL{[compose-multiplatform-patterns.md](compose-multiplatform-patterns.md); [kotlin-coroutines-flows.md](kotlin-coroutines-flows.md)}
