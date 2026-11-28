@REF:nodejs-keccak256

§SCOPE{eth(selectors,topics,EIP-712,sig,merkle,slots)∈JS/TS∨crypto_audit}

§R{
  eth≡Keccak-256(original_0x01_padding)≠NIST_SHA3-256(0x06_padding);
  `crypto.createHash('sha3-256').update(s).digest('hex')!==keccak256(toUtf8Bytes(s)).slice(2)`(silent_mismatch,wrong_slots/sigs/addrs);
  ∀eth:¬`createHash('sha3-256')`∧¬`web3.js`(archived/sunset_2025-03-04)⇒`viem`_v2|`ethers`_v6|`@noble/hashes`_v2
}

§PAT{
  viem_v2[preferred]:
    `import {keccak256,toBytes,toHex,toFunctionSelector,encodeAbiParameters,encodePacked} from 'viem';`
    hash:`keccak256(toBytes('hello'))`|`keccak256('0x1234')`|bytes_out:`keccak256(toBytes('hello'),'bytes')`;
    sel:`toFunctionSelector('transfer(address,uint256)')`;
    topic:`keccak256(toBytes('Transfer(address,address,uint256)'))`;
    packed:`keccak256(encodePacked(['address','uint256'],[A,100n]))`;
    slot:`keccak256(encodeAbiParameters([{type:'address'},{type:'uint256'}],[key,mappingSlot]))`;
  ethers_v6(A='0x742d35Cc6634C0532925a3b8D4C9B569890FaC1c'):
    `keccak256(new Uint8Array([0x01,0x02]))`;`keccak256(toUtf8Bytes('hello'))`;`id('Transfer(address,address,uint256)')`;`solidityPackedKeccak256(['address','uint256'],[A,100n])`;
    sel:`id('transfer(address,uint256)').slice(0,10)`;
    712:`keccak256(toUtf8Bytes('Transfer(address from,address to,uint256 value)'))`;
    slot:`keccak256(AbiCoder.defaultAbiCoder().encode(['address','uint256'],[key,mappingSlot]))`;
    addr:`'0x'+keccak256(pubkeyBytes.slice(1)).slice(-40)`;
  noble_v2[zero_dep_audited]:
    `import {keccak_256} from '@noble/hashes/sha3.js';`(BREAKING_v2:explicit_`.js`_subpath_required_for_ESM;v1_omitted_`.js`);
    `const digest=keccak_256(new TextEncoder().encode('hello'));`
}

§ANTI{
  ¬`node:crypto`_`createHash('sha3-256')`_for_EVM(NIST_padding≠Keccak);
  ¬`web3.js`(ChainSafe_sunset_2025-03-04)∨legacy_native_C++_`keccak`_addon⇒migrate_to_`viem`/`ethers`_v6/`@noble/hashes`_v2;
  ¬omit_`.js`_in_`@noble/hashes`_v2_imports(`ERR_MODULE_NOT_FOUND`)
}

§CMD{
  `grep -rn "createHash.*sha3" --include="*.ts" --include="*.js" --exclude-dir=node_modules .`
  `grep -rn "keccak256\|keccak_256" --include="*.ts" --include="*.js" --exclude-dir=node_modules .`
  `grep -rn "from ['\"]web3['\"]\|from ['\"]@noble/hashes/sha3['\"]" --include="*.ts" --include="*.js" --exclude-dir=node_modules .`
}
