List of Known Actions
=====================

### Contract: `crittermanager`

```bash
curl https://raw.githubusercontent.com/hive-engine/steemsmartcontracts/master/contracts/crittermanager.js | grep "actions." | cut -f 2 -d '.' | cut -f 1 -d ' ' | cut -f 1 -d '('
```

```
updateParams
createNft
updateName
hatch
```

### Contract: `inflation`

```bash
curl https://raw.githubusercontent.com/hive-engine/steemsmartcontracts/master/contracts/inflation.js | grep "actions." | cut -f 2 -d '.' | cut -f 1 -d ' ' | cut -f 1 -d '('
```

```
issueNewTokens
```

### Contract: `market`

```bash
curl https://raw.githubusercontent.com/hive-engine/steemsmartcontracts/master/contracts/market.js | grep "actions." | cut -f 2 -d '.' | cut -f 1 -d ' ' | cut -f 1 -d '('
```

```
cancel
buy
sell
```

### Contract: `nft`

```bash
curl https://raw.githubusercontent.com/hive-engine/steemsmartcontracts/master/contracts/nft.js | grep "actions." | cut -f 2 -d '.' | cut -f 1 -d ' ' | cut -f 1 -d '('
```

```
updateParams
updateUrl
updateMetadata
updateName
addAuthorizedIssuingAccounts
addAuthorizedIssuingContracts
removeAuthorizedIssuingAccounts
removeAuthorizedIssuingContracts
transferOwnership
enableDelegation
addProperty
setPropertyPermissions
setGroupBy
setProperties
burn
transfer
delegate
undelegate
checkPendingUndelegations
create
addAuthorizedIssuingAccounts
addAuthorizedIssuingContracts
issue
issueMultiple
```

### Contract: `nftmarket`

```bash
curl https://raw.githubusercontent.com/hive-engine/steemsmartcontracts/master/contracts/nftmarket.js | grep "actions." | cut -f 2 -d '.' | cut -f 1 -d ' ' | cut -f 1 -d '('
```

```
enableMarket
changePrice
cancel
buy
sell
```

### Contract: `steempegged`

```bash
curl https://raw.githubusercontent.com/hive-engine/steemsmartcontracts/master/contracts/steempegged.js | grep "actions." | cut -f 2 -d '.' | cut -f 1 -d ' ' | cut -f 1 -d '('
```

```
buy
withdraw
removeWithdrawal
```

### Contract: `tokens`

```bash
curl https://raw.githubusercontent.com/hive-engine/steemsmartcontracts/master/contracts/tokens.js | grep "actions." | cut -f 2 -d '.' | cut -f 1 -d ' ' | cut -f 1 -d '('
```

```
updateParams
updateUrl
updateMetadata
updatePrecision
transferOwnership
create
transfer
issue
issueToContract
transfer
transferToContract
transferFromContract
checkPendingUnstakes
enableStaking
stake
stakeFromContract
unstake
cancelUnstake
enableDelegation
delegate
undelegate
checkPendingUndelegations
```

### Contract: `witnesses`

```bash
curl https://raw.githubusercontent.com/hive-engine/steemsmartcontracts/master/contracts/witnesses.js | grep "actions." | cut -f 2 -d '.' | cut -f 1 -d ' ' | cut -f 1 -d '('
```

```
updateWitnessesApprovals
register
approve
disapprove
proposeRound
scheduleWitnesses
```
