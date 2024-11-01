import { React, useState } from 'react';
import { Dropdown } from 'react-bootstrap';
import { useDispatch } from 'react-redux';
import { loadPackagesDevnet, loadPackagesMainnet} from "./package_select"

const DropTab = () => {
    const dispatch = useDispatch()
    const[devnet, setDevnet] = useState(false);

    const[packageSelected, setPackageSelected] = useState(false);
    const selectDevnet = async () => {
        const devnet = await loadPackagesDevnet(dispatch);
        console.log(devnet)

        setDevnet(true);
        setPackageSelected(true)
    };

    const selectMainnet = async () => {
        const mainnet = await loadPackagesMainnet(dispatch);
        console.log(mainnet)
        
        setDevnet(false);
        setPackageSelected(true)


    };

    return (
        <Dropdown>
            {!packageSelected ? (
                <Dropdown.Toggle variant="success" id="dropdown-basic">
                Choose your package
            </Dropdown.Toggle>
            ) : (<>{ devnet? (
                <Dropdown.Toggle variant="success" id="dropdown-basic">
                Devnet Package Selected
            </Dropdown.Toggle>
                ):(
                    <Dropdown.Toggle variant="success" id="dropdown-basic">
                Mainnet Package Selected
            </Dropdown.Toggle>
                )}</>
            )}

            <Dropdown.Menu>
                <Dropdown.Item onClick={selectDevnet}>- Devnet Package</Dropdown.Item>
                <Dropdown.Item onClick={selectMainnet}>- Mainnet Package</Dropdown.Item>
            </Dropdown.Menu>
        </Dropdown>
    );
}

export default DropTab;
