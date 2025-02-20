import React from "react";
import { ConnectButton } from "@mysten/dapp-kit";

const NavBar: React.FC = () => {

  return (
    <div className="bg-transparent p-4 w-full">
      <div className="flex justify-end">
        <ConnectButton />
      </div>
    </div>
  );
};

export default NavBar;
