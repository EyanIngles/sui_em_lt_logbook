
import "./App.css";
import { loadOther } from "./functions/item_functions";
import { loadAccount } from "./functions/package_select";
import DropTab from "./functions/dropdown";

import { Button } from "react-bootstrap";
import { useDispatch } from "react-redux";
import { useEffect, useState } from "react";
//sui stuff
import { getFullnodeUrl, SuiClient } from '@mysten/sui/client';
import { Transaction } from "@mysten/sui/transactions";
import {
  ConnectButton,
  useCurrentAccount,
  useAccounts
} from "@mysten/dapp-kit";

function App() {
  const currentAccount = useCurrentAccount();
  const [account, setAccount] = useState(null);

  const dispatch = useDispatch();
  const accounts = useAccounts();
  const RPC = getFullnodeUrl(`devnet`); // need to add the network fetcher
  //const RPC = getFullnodeUrl(`${network}`); // need to add the network fetcher
  const Client = new SuiClient({ url: RPC });

  const connect = async () => {
    await loadOther(dispatch);
    console.log("connect")
  }
  const connect1 = async () => {
    console.log("connect1")
  }
  const connect2 = async () => {
    console.log("connect2")
  }
  const connect3 = async () => {
    console.log("connect3")
  }
  const connect4 = async () => {
    console.log("connect4")
  }

  useEffect(() => {
    const fetchAccount = async () => {
        if (currentAccount) {
            // client setup

            //await loadClient(Client, dispatch);

            // account setup
            const account = accounts[0];
            await loadAccount(account.address, dispatch);
            setAccount(account.address.toString());
            // Add any additional actions here
        }
    };
    fetchAccount();
}, [currentAccount, Client, dispatch]); // need to add network to this array.
  return (
    <div className="App">
      <header className="App-header">
        {currentAccount ? (
          <>
            <DropTab /> <hr />
            <Button onClick={connect}>button</Button> <hr/>
            <Button onClick={connect1}>button 1</Button><br/>
            <Button onClick={connect2}>button 2</Button><br/>
            <Button onClick={connect3}>button 3</Button><br/>
            <Button onClick={connect4}>button 4</Button><br/>

          </>
        ) : (
          <>
            <ConnectButton className="Connect" />
            <hr />
          </>
        )}
      </header>
    </div>
  );
}

export default App;
