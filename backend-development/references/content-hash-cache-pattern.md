@REF:content-hash-cache-pattern
# SHA-256 content-hash file cache; survives move/rename, auto-invalidates on content Δ.
§WHEN{file_pipelines(PDF,img,text);high_cost+repeat_files;`--cache/--no-cache`_CLI;wrap_pure_fn_unmodified}
§SKIP{realtime/fresh_data;huge_entries(stream);output_depends_on_extra_params/configs}
§PAT{
```python
import hashlib, json
from dataclasses import dataclass
from pathlib import Path
_HASH_CHUNK_SIZE = 65536  # 64KB
def compute_file_hash(path: Path) -> str:
    if not path.is_file(): raise FileNotFoundError(f"File not found: {path}")
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while (c := f.read(_HASH_CHUNK_SIZE)): h.update(c)
    return h.hexdigest()
@dataclass(frozen=True, slots=True)
class CacheEntry:
    file_hash: str; source_path: str; document: ExtractedDocument
def write_cache(cache_dir: Path, entry: CacheEntry) -> None:
    cache_dir.mkdir(parents=True, exist_ok=True)
    (cache_dir / f"{entry.file_hash}.json").write_text(json.dumps(serialize_entry(entry), ensure_ascii=False), encoding="utf-8")
def read_cache(cache_dir: Path, file_hash: str) -> CacheEntry | None:
    p = cache_dir / f"{file_hash}.json"
    if not p.is_file(): return None
    try: return deserialize_entry(json.loads(p.read_text(encoding="utf-8")))
    except (json.JSONDecodeError, ValueError, KeyError): return None
def extract_with_cache(file_path: Path, *, cache_enabled: bool = True, cache_dir: Path = Path(".cache")) -> ExtractedDocument:
    if not cache_enabled: return extract_text(file_path)
    h = compute_file_hash(file_path)
    if (c := read_cache(cache_dir, h)) is not None:
        logger.info("Cache hit: %s (hash=%s)", file_path.name, h[:12]); return c.document
    logger.info("Cache miss: %s (hash=%s)", file_path.name, h[:12])
    doc = extract_text(file_path)
    write_cache(cache_dir, CacheEntry(file_hash=h, source_path=str(file_path), document=doc))
    return doc
```
}
§R{SHA256_content(¬path);64KB_chunks;`{hash}.json`(O(1),no_index);SRP_wrapper(pure_extract);manual_JSON_ser(frozen_dataclass);corrupt⇒None(miss);lazy_mkdir;log_hit/miss(`[:12]`)}
§ANTI{path_key(`{"/path/to/file.pdf":res}`);cache_in_`extract_text`(SRP_viol);`dataclasses.asdict(entry)`_on_nested_frozen_dataclasses}
