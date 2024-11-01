
import "./App.css";
import { loadOther } from "./functions/bet_create";
import DropTab from "./functions/dropdown";

import { Button } from "react-bootstrap";
import { useDispatch } from "react-redux";
import { useState } from "react";
//sui stuff
import { Transaction } from "@mysten/sui/transactions";
import {
  ConnectButton,
  useCurrentAccount,
  useSignTransaction,
  ConnectModal,
} from "@mysten/dapp-kit";

function App() {
  const currentAccount = useCurrentAccount();
  const [open, setOpen] = useState(false);
  const dispatch = useDispatch();

  const connect = async () => {
    await loadOther(dispatch);
  };
  return (
    <div className="App">
      <header className="App-header">
        {currentAccount ? (
          <>
            <DropTab /> <hr />
            <Button onClick={connect}>setting data</Button>
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
