@REF:nodejs-keccak256
§SCOPE{eth(selectors,topics,EIP-712,sig,merkle,slots)∈JS/TS∨crypto_audit}
§R{eth≡Keccak-256≠NIST_SHA3-256;crypto.createHash('sha3-256').update(s).digest('hex')!==keccak256(toUtf8Bytes(s)).slice(2)(silent);∀eth:¬createHash('sha3-256')⇒ethers|viem|web3|keccak}
§PAT{
  ethers_v6(A='0x742d35Cc6634C0532925a3b8D4C9B569890FaC1c'):
  keccak256(new Uint8Array([0x01,0x02]));keccak256(toUtf8Bytes('hello'));id('Transfer(address,address,uint256)');solidityPackedKeccak256(['address','uint256'],[A,100n]);sel:id('transfer(address,uint256)').slice(0,10);712:keccak256(toUtf8Bytes('Transfer(address from,address to,uint256 value)'));slot:keccak256(AbiCoder.defaultAbiCoder().encode(['address','uint256'],[key,mappingSlot]));addr:'0x'+keccak256(pubkeyBytes.slice(1)).slice(-40);
  viem:keccak256(toBytes('hello'));
  web3:web3.utils.{keccak256('hello'),soliditySha3({type:'address',value:A},{type:'uint256',value:'100'})}
}
§CMD{
  grep -rn "createHash.*sha3" --include="*.ts" --include="*.js" --exclude-dir=node_modules .
  grep -rn "keccak256" --include="*.ts" --include="*.js" . | grep -v node_modules
}
