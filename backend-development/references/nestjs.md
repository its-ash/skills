@REF:nestjs
§USE{NestJS_12(native_ESM,Node_20.19+/22.12+/24/26+,Standard_Schema)|NestJS_11_legacy;DI_err("cannot resolve dependencies"|circular);controllers/DTO_val/serialization;Prisma_7|TypeORM|Mongoose;JWT/Passport;unit|int|e2e;perf/cache/mem_leaks}
§PAT{Modules_DI
  `@Module({imports:[CommonModule,DatabaseModule],controllers:[FeatureController],providers:[FeatureService,FeatureRepository],exports:[FeatureService]})`;
  small,feature-first,loosely_coupled;`@Injectable()` on services;export ONLY needed providers;custom tokens⇒`Symbol`∨unique_str∧match`@Inject()`;
  errs:¬`providers`→"cannot resolve dependencies";¬`exports`→unresolvable;circular→`forwardRef(()=>OtherModule)` both sides⊕3rd module;
  CLI:`nest generate module|service <name>`;
  `@Global() @Module({providers:[ConfigService],exports:[ConfigService]})`;
  dynamic:`static forRoot(o:FeatureOptions):DynamicModule=>({module:FeatureModule,providers:[{provide:'FEATURE_OPTIONS',useValue:o}],exports:['FEATURE_OPTIONS']})`
}
§PAT{Controllers_Pipeline
  thin:`@Controller('users')`,`@Get(':id')`,`@Post()`,`@Param('id',ParseUUIDPipe)`,`@Body() dto`;parse→provider→response DTO;¬return ORM entities(leaks hashes,tokens,audit_cols);
  validation:NestJS_12_1st_class_Standard_Schema(Zod_4/Valibot/ArkType directly in `@Body()`/`@Query()`/`@Param()`)∨`class-validator`(`@IsEmail()`,`@IsString()`,`@Length(2,80)`,`@IsOptional()`,`@IsEnum(UserRole)`)+`class-transformer`(`@Exclude()`,`@Expose()`);
  fixes:route_conflict→unique path+verb;missing_val→`@Body()` schema/DTO;serialization→`@Exclude()`/`@Expose()`+`ClassSerializerInterceptor(app.get(Reflector))`∨explicit_response_mapper;
  order:`Middleware→Guards→Interceptors(before)→Pipes→Handler→Interceptors(after)`;
  guard:`@Injectable() export class JwtAuthGuard extends AuthGuard('jwt'){}`;coarse(role,auth)⇒Guards(`@UseGuards(JwtAuthGuard,RolesGuard)`+`@Roles('admin')`);ownership⇒Service;
  decorator:`Roles=(...r:string[])=>SetMetadata('roles',r);Auth=(...r:string[])=>applyDecorators(UseGuards(JwtAuthGuard,RolesGuard),Roles(...r));`;
  interceptor:`@Injectable() implements NestInterceptor{intercept(ctx:ExecutionContext,next:CallHandler){return next.handle();}}`;
  pitfalls:¬`await` in async guard/interceptor→hangs;wrong `@UseGuards` placement→skipped
}
§PAT{Testing_Persistence
  unit:`Test.createTestingModule({providers:[MyService,{provide:DepService,useValue:mockDep}]}).compile()`→`moduleRef.get(MyService)`;TypeORM:`{provide:getRepositoryToken(User),useValue:mockRepository}`;
  e2e:`import request from 'supertest';const app=module.createNestApplication();configureApp(app);await app.init();await request(app.getHttpServer()).post('/auth/login').send({username,password}).expect(201);`;
  rules:share `configureApp(app)`(pipes,interceptors,filters) across `main.ts`∧e2e;int_tests use Testcontainers∨test_DB;order:`npm run build&&npm test&&npm run test:e2e`;
  Prisma_7:wrap `PrismaClient` in `PrismaService implements OnModuleInit,OnModuleDestroy`;tx:`$transaction`;extensions:`$extends`(¬removed `$use`);
  TypeORM:`TypeOrmModule.forFeature([User,Post])`;named_DBs:`forRoot({name:'users',...})`+`forFeature([User],'users')`;`retryAttempts:3,retryDelay:2000`;use `DataSource` config(¬removed `ormconfig.json`);
  Mongoose:`MongooseModule.forFeature([{name:Cat.name,schema:CatSchema}])`;check`@Prop()`;
  tx:ORM behind domain providers;unit-of-work service owns tx(Prisma `$transaction`,TypeORM `DataSource.transaction`);¬multi-write in controller
}
§PAT{Auth_Config_Errors
  Passport_JWT:`npm i @nestjs/passport @nestjs/jwt passport-jwt`;
  `JwtStrategy extends PassportStrategy(Strategy)`(`Strategy` from `'passport-jwt'`),`super({jwtFromRequest:ExtractJwt.fromAuthHeaderAsBearerToken(),secretOrKey:config.getOrThrow('JWT_SECRET')})`,`validate(p)=>({userId:p.sub,username:p.username})`;
  route:`@UseGuards(JwtAuthGuard) @Get('profile') getProfile(@Request() req){return req.user;}`;
  fixes:`"Unknown authentication strategy 'jwt'"`→import `Strategy` from `passport-jwt`;`secretOrPrivateKey must have a value`→`JWT_SECRET` in `.env`∧`ConfigModule` before `JwtModule`;`401`→check `Authorization: Bearer <token>`∧expiry;
  Config(boot-validated,fail-fast):`ConfigModule.forRoot({isGlobal:true,load:[configuration],validate:validateEnv})`(Zod_4/Valibot/Joi);
  async_DI:`TypeOrmModule.forRootAsync({imports:[ConfigModule],useFactory:(c:ConfigService)=>({type:'postgres',host:c.getOrThrow('DB_HOST')}),inject:[ConfigService]})`;
  Errors_Logging:`@Catch(HttpException)`⇒HTTP only;`@Catch()`⇒all(¬stack_trace leak);
  `AllExceptionsFilter implements ExceptionFilter`:`ctx=host.switchToHttp();res=ctx.getResponse<Response>();req=ctx.getRequest<Request>();` if `ex instanceof HttpException`→`res.status(ex.getStatus()).json({path:req.url,error:ex.getResponse()})`;else `this.logger.error(ex);res.status(500).json({path:req.url,error:'Internal server error'})`;
  register:`app.useGlobalFilters(new AllExceptionsFilter())`;use `nestjs-pino`∨Nest `Logger`(JSON prod+correlation_ID);await all promises∨`.catch()`
}
§CFG{Prod_Layout_Bootstrap
  layout:`src/{app.module.ts,main.ts,common/(filters,guards,interceptors,pipes,decorators),config/{configuration.ts,validation.ts},modules/{auth/(controller,module,service,dto/,guards/,strategies/),users/(controller,module,service,dto/,entities/)},prisma/|database/}`;
  scope:domain in feature modules,DTOs/schemas near owning module,cross-cutting only in `common/`;
  adapter:Fastify(`@nestjs/platform-fastify`,high_throughput)∨Express_5(default);
  bootstrap:`NestFactory.create(AppModule,{bufferLogs:true})`→`app.useGlobalPipes(new ValidationPipe({whitelist:true,forbidNonWhitelisted:true,transform:true,transformOptions:{enableImplicitConversion:true}}))`(1 global pipe,¬repeat;or Standard_Schema pipe in v12)→`app.useGlobalInterceptors(new ClassSerializerInterceptor(app.get(Reflector)))`→`app.useGlobalFilters(new AllExceptionsFilter())`→`app.enableShutdownHooks()`→`await app.listen(process.env.PORT??3000)`;
  defaults:async DB/cache+`@nestjs/terminus` healthchecks;bg_jobs/consumers(`@nestjs/bullmq`) in own modules(¬HTTP controllers);`@nestjs/throttler`+auth+audit_logs on public endpoints;`@nestjs/cache-manager`/Redis;¬N+1(DataLoader/query_builder);clean listeners in `onModuleDestroy`
}
§CMD{Diagnostic_Verify
  detect:`test -f nest-cli.json`;`grep -q "@nestjs/core" package.json`;`grep "@nestjs/core" package.json|sed -E 's/.*"([0-9\.]+)".*/Nest version: \1/'`;
  modules:`find src -name "*.module.ts"|head -5|xargs -n1 basename -s .module.ts`;
  deps:`grep -qE "@nestjs/(typeorm|mongoose|passport|jwt|platform-fastify)" package.json`;
  check:`npm run lint&&npm run build -- --watch=false`;verify:`npm run build&&npm test&&npm run test:e2e`
}
§CHK{Done_Gate
  0_type_errors∧all_tests_pass(unit+int+e2e)∧¬circular_deps∧valid_JWT_auth∧stable_DB∧JSON_logs∧¬N+1∧cache+shutdown_cleanup∧SLA_met
}
§REL{../SKILL.md,../../typescript/SKILL.md,../../node/SKILL.md,../../database-design/SKILL.md}
