@REF:android-clean-architecture
§SCOPE{Android∧KMP:modules,DI,UseCase/Repo/DS,domain↔data↔pres,Koin/Hilt,Room/SQLDelight/Ktor}
§MOD{
  dirs:{app/:entry+DI+Application,core/:utils+base+err,domain/:UseCases+models+repo_ifaces(pure_Kt),data/:repo_impls+DS+DB+net,presentation/:Screens+VMs+UI+nav,design-system/:Compose+theme+type,feature/{auth,settings,profile}/:opt_large};
  deps:{app→{presentation,domain,data,core},presentation→{domain,design-system,core},data→{domain,core},domain→core∨∅,core→∅};
  §R:domain∩{data,presentation,android_fw,fw_ann}≡∅
}
§PAT{domain:
  UseCase(1_op/cls,`operator fun invoke`):`suspend operator fun invoke(cat:String):Result<List<Item>>`|`operator fun invoke(uid:String):Flow<UserProgress>`;
  Model(plain_Kt,¬fw_ann):`data class`/`enum class(DRAFT,ACTIVE,ARCHIVED)`;
  RepoIface(domain→data_impl):`suspend getItemsByCategory(cat):Result<List<Item>>`;`suspend saveItem(item):Result<Unit>`;`observeItems():Flow<List<Item>>`
}
§PAT{data:
  RepoImpl(local,remote):fetch=`runCatching{local.insertItems(remote.fetchItems(cat).map(Dto::toEntity));local.getItemsByCategory(cat).map(Entity::toDomain)}`;save=`runCatching{local.insertItems(listOf(item.toEntity()))}`;observe=`local.observeAll().map{it.map(Entity::toDomain)}`;
  Mapper(ext∈data):`Entity.toDomain()`(`tags.split("|")`,`Status.valueOf(status)`),`Dto.toEntity()`(`tags.joinToString("|")`);
  Room(Android):`@Entity(tableName="items")(@PrimaryKey val id:String,...)`;`@Dao`:`@Query("SELECT * FROM items WHERE category = :category") suspend fun getByCategory(cat):List<ItemEntity>`,`@Upsert suspend fun upsert(items:List<ItemEntity>)`,`@Query("SELECT * FROM items") fun observeAll():Flow<List<ItemEntity>>`;
  SQLDelight(KMP,`Item.sq`):`CREATE TABLE ItemEntity(id TEXT NOT NULL PRIMARY KEY,...);getByCategory:SELECT * FROM ItemEntity WHERE category=?;upsert:INSERT OR REPLACE INTO ItemEntity(...) VALUES(...);observeAll:SELECT * FROM ItemEntity;`;
  Ktor(KMP):`client.get("api/items"){parameter("category",cat)}.body<List<ItemDto>>()`, `HttpClient{install(ContentNegotiation){json(Json{ignoreUnknownKeys=true})};install(Logging){level=LogLevel.HEADERS};defaultRequest{url("https://api.example.com/")}}`
}
§PAT{di:
  Koin(KMP,`module{...}`):`factory{UseCase(get())}`(domain);`single<Repo>{RepoImpl(get(),get())};single{LocalDS(get())};single{RemoteDS(get())}`(data);`viewModelOf(::VM)`(pres);
  Hilt(Android):`@Module @InstallIn(SingletonComponent::class) abstract class RepoModule{@Binds abstract fun bind(impl:RepoImpl):Repo}`;`@HiltViewModel class VM @Inject constructor(uc:UseCase):ViewModel()`
}
§PAT{err:
  `Result<T>`⊕`sealed interface Try<out T>{data class Success<T>(val value:T):Try<T>;data class Failure(val error:AppError):Try<Nothing>}`;
  `sealed interface AppError{data class Network(val msg:String):AppError;data class Database(val msg:String):AppError;data object Unauthorized:AppError}`;
  VM(`viewModelScope.launch`):`_state.update{when(r){is Try.Success->it.copy(items=r.value,isLoading=false);is Try.Failure->it.copy(error=r.error.toMessage(),isLoading=false)}}`
}
§CFG{gradle_conv:
  `build-logic/src/main/kotlin/kmp-library.gradle.kts`:`plugins{id("org.jetbrains.kotlin.multiplatform")};kotlin{androidTarget();iosX64();iosArm64();iosSimulatorArm64();sourceSets{commonMain.dependencies{};commonTest.dependencies{implementation(kotlin("test"))}}}`;
  module:`plugins{id("kmp-library")}`
}
§ANTI{¬import(Android_fw∈domain);¬expose(Entity∨Dto→UI;map→domain);¬logic∈VM(→UseCase);¬GlobalScope∨unstructured(→viewModelScope∨structured);¬fat_repo(→DataSources);¬circular_deps(A→B⇒¬(B→A))}
§REL{[compose-multiplatform-patterns.md](compose-multiplatform-patterns.md);[kotlin-coroutines-flows.md](kotlin-coroutines-flows.md)}
