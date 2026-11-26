@REF:core-guidelines
§SRC:https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines

§R:CrossCutting{
  RAII:{P.8,R.1,E.6,CP.20};immutability:{P.10,Con.1-5,ES.25};type_safety:{P.4,I.4,ES.46-49,Enum.3};
  intent:{P.3,F.1,NL.1-2,T.10};min_complexity:{F.2-3,ES.5,Per.4-5};value>ptr:{C.10,R.3-5,F.20,CP.31}
}

§PAT:P_I{
  P.1/P.3:express_intent;P.4/P.5:static_type_safety∧compile>runtime;P.8:¬leak;P.10:immutable;
  I.1/I.4:explicit_strongly_typed_ifaces;I.2:¬non_const_globals;I.11:¬own_transfer_via_raw_ptr/ref;I.23:low_arg_count;
  ex:`struct Temperature{double kelvin;}; Temperature boil(const Temperature&);`¬`double boil(double*);`
}

§PAT:F{
  F.1-3:named+single_purpose+short;F.4:`constexpr`;F.6:`noexcept`;F.8:pure;
  F.16:in(cheap→val,else→`const&`;sink→val+move);F.20/21:ret_val/struct>out_params;F.43:¬ret_ptr/ref_to_local;
  anti:{F.45:ret_`T&&`,F.55:va_arg,F.53:ref_lambda_capture_cross_thread,F.49:ret_`const T`(blocks_move)};
  ex:`struct ParseResult{std::string token;int position;}; constexpr int factorial(int n)noexcept;`
}

§PAT:C{
  C.2:`class`(invariant)⊕`struct`(indep);C.9:min_exposure;C.20:Rule_of_Zero;C.21:Rule_of_Five(def/`=delete`_1⇒all);
  C.35:base_dtor=public_virtual∨protected_non_virtual;C.41:ctor_fully_inits;C.46:single_arg_ctor=`explicit`;
  C.67:polymorphic_suppresses_public_copy/move;C.121:pure_iface=abstract_pure_virtuals;C.128:exactly_1(`virtual`⊕`override`⊕`final`);
  anti:{C.82:virtual_in_ctor/dtor,C.90:memset/memcpy_non_trivial,C.140:diff_default_args_override,C.12:`const`/ref_members}
}

§PAT:R{
  R.1:RAII_all;R.3:raw_`T*`=non_owning;R.5:scoped>heap;R.10/11:¬malloc/free/new/delete;
  R.13:1_alloc/expr;R.20/21:`unique_ptr`(default)⊕`shared_ptr`(shared_only);R.22:`make_shared`;
  copy_assign_safety:temp_alloc(`make_unique<char[]>(n)`+`copy_n`)+`data_=std::move(tmp)`+`=default`_noexcept_moves
}
```cpp
class FileHandle {
    std::FILE* h_;
public:
    explicit FileHandle(const std::string& p) : h_(std::fopen(p.c_str(), "r")) { if (!h_) throw std::runtime_error(p); }
    ~FileHandle() { if (h_) std::fclose(h_); }
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;
    FileHandle(FileHandle&& o) noexcept : h_(std::exchange(o.h_, nullptr)) {}
    FileHandle& operator=(FileHandle&& o) noexcept { if (this != &o) { if (h_) std::fclose(h_); h_ = std::exchange(o.h_, nullptr); } return *this; }
};
```

§PAT:ES{
  ES.5:small_scopes;ES.12:¬shadow_nested;ES.20/23:always_init(`{}`);ES.25:`const`/`constexpr`;
  ES.28:IILE_complex_const_init(`const auto c=[&]{...}();`);ES.45:named_consts(¬magic);
  ES.46:¬narrowing;ES.47:`nullptr`¬0/NULL;ES.48/50:named_casts_only∧¬cast_away_`const`;ES.100:¬mix_signed_unsigned
}

§PAT:E{
  E.1:strategy_early;E.2:throw_on_failure;E.3:¬flow_ctrl;E.6:RAII;E.12:`noexcept`;
  E.14:typed_exceptions(¬int/literal);E.15:throw_val_catch_ref;E.16:dtor/dealloc/`swap`_¬fail;
  E.17:¬catch_all_everywhere;E.28:¬`errno`/globals;¬empty_catch;
  ex:`class AppError:public std::runtime_error{using runtime_error::runtime_error;};`
}

§PAT:Con{Con.1:immutable_obj;Con.2:`const`_methods;Con.3:ptr/ref_to_`const`;Con.4:`const`_post_ctor;Con.5:`constexpr`_compile}

§PAT:CP{
  CP.2/3:¬race∧min_shared_mut;CP.4:tasks>threads;CP.8:¬`volatile`_sync(HW_IO_only);
  CP.20:RAII_locks(¬`lock`/`unlock`);CP.21:`std::scoped_lock`(multi_mutex);CP.22:¬callbacks_under_lock;
  CP.26:¬detach;CP.42:¬wait_uncond(`cv.wait(lk,pred)`);CP.44:name_locks;CP.50:mutex_with_data;CP.100:¬lock_free_unless_must;
  anti:`std::lock_guard<std::mutex>(m_);`
}

§PAT:T{
  T.1/2:abstraction+generic;T.10/11:concepts_all_args(std_first);T.13:shorthand(`void sort(std::ranges::random_access_range auto& r)`);
  T.43:`using`>`typedef`;T.47:¬unconstrained_visible;T.120:TMP_only_if_`constexpr`_cant;T.144:overload¬specialize_fn_tmpl;
  ex:`template<typename T> concept Serializable=requires(const T& t){{t.serialize()}->std::convertible_to<std::string>;};`
}

§PAT:SL_Enum_SF_NL_Per{
  SL:{SL.1/2:std_first,SL.con.1/2:`array`/`vector`(default)>C_array,SL.str.1/2:`string`(own)|`string_view`(obs),SL.io.50:`'\n'`>`std::endl`};
  Enum:{Enum.1:enum/`constexpr`>macro,Enum.3:`enum class`>enum,Enum.5:¬ALL_CAPS_enumerators,Enum.6:¬unnamed};
  SF:{SF.1:.cpp/.h,SF.7:¬global_`using namespace`_in_.h,SF.8:guards/`#pragma once`,SF.10/11:self_contained_.h};
  NL:{NL.5:¬Hungarian,NL.8/10:`underscore_style`,NL.9:ALL_CAPS_macros_only,members_trailing:`_`};
  Per:{Per.1/2:¬premature,Per.4/5:clear>clever,Per.6:measure,Per.7:design_for_opt,Per.10:static_types,Per.11:compile_time(`constexpr`),Per.19:contiguous(`vector<Point>`>`vector<unique_ptr<Point>>`)}
}
