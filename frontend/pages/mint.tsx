import {
  Container,
  Divider,
  FormControl,
  Grid,
  MenuItem,
  Select,
  Typography,
} from '@mui/material'
import { LoadingButton } from '@mui/lab'
import { useEffect, useState } from 'react'
import {
  Address,
  useAccount,
  useContractReads,
  useContractWrite,
  usePrepareContractWrite,
} from 'wagmi'
import { ethers } from 'ethers'

import SampleSale from '../../solidity/artifacts/contracts/SampleSale.sol/SampleSale.json'

const sampleSaleContract = {
  address: '0x1bD73E93252204cF7a2aAff5B5cADECC05ebb712' as Address,
  abi: SampleSale.abi,
}
const Mint = () => {
  const [price, setPrice] = useState('0')
  const [preSaleRemaining, setPreSaleRemaining] = useState('0')
  const [totalSupply, setTotalSupply] = useState('0')
  const [supply, setSupply] = useState('0')
  const [preSaleLimit, setPreSaleLimit] = useState('0')
  const [publicSaleRemaining, setPublicSaleRemaining] = useState('0')
  const [publicSaleLimit, setPublicSaleLimit] = useState('0')
  const [isEligible, setIsEligible] = useState(false)

  const [amount, setAmount] = useState(1)

  const { address } = useAccount()

  const InputText = () => {
    const handleChange = (event: any) => {
      setAmount(event.target.value)
    }

    const range = Number(preSaleRemaining)

    return (
      <FormControl fullWidth>
        <Select value={amount} onChange={handleChange} sx={{ height: '39px' }}>
          {[...Array(range)].map((_, i) => (
            <MenuItem key={i + 1} value={i + 1}>
              {i + 1}
            </MenuItem>
          ))}
        </Select>
      </FormControl>
    )
  }

  const { data } = useContractReads({
    contracts: [
      {
        ...sampleSaleContract,
        functionName: 'price',
      },
      {
        ...sampleSaleContract,
        functionName: 'checkPreSaleRemaining',
        args: [address],
      },
      {
        ...sampleSaleContract,
        functionName: 'totalSupply',
      },
      {
        ...sampleSaleContract,
        functionName: 'supply',
      },
      {
        ...sampleSaleContract,
        functionName: 'preSaleLimit',
      },
      {
        ...sampleSaleContract,
        functionName: 'publicSaleLimit',
      },
      {
        ...sampleSaleContract,
        functionName: 'checkPublicSaleRemaining',
        args: [address],
      },
      {
        ...sampleSaleContract,
        functionName: 'checkPreSaleEligible',
        args: [
          address,
          [
            '0x8502b689d00e239f46554454edf912b4b09d7d4a6ce1c4b0ee3fc239e33107f9',
          ],
        ],
      },
    ],
  })

  const mintConfig = usePrepareContractWrite({
    ...sampleSaleContract,
    functionName: 'preSaleMint',
    args: [
      amount,
      ['0x8502b689d00e239f46554454edf912b4b09d7d4a6ce1c4b0ee3fc239e33107f9'],
    ],
    overrides: {
      value: ethers.utils.parseEther(
        (Number(price) * Number(amount)).toString()
      ),
    },
  }).config
  const mint = useContractWrite({
    ...mintConfig,
  })

  useEffect(() => {
    setPrice(
      data ? ethers.utils.formatEther((data[0] as String).toString()) : '0'
    )
    setPreSaleRemaining(data ? (data[1] as String).toString() : '0')
    setTotalSupply(data ? (data[2] as String).toString() : '0')
    setSupply(data ? (data[3] as String).toString() : '0')
    setPreSaleLimit(data ? (data[4] as String).toString() : '0')
    setPublicSaleLimit(data ? (data[5] as String).toString() : '0')
    setPublicSaleRemaining(data ? (data[6] as String).toString() : '0')
    setIsEligible(data ? (data[7] as boolean) : false)
  }, [address])

  const handleClick = async () => {
    mint.write?.()
  }

  return (
    <Container>
      <Grid container alignItems="center" justifyContent="center">
        <Grid
          container
          border={2}
          borderColor="white"
          width={550}
          alignItems="center"
          justifyContent="center"
        >
          <Grid container width={500}>
            <Grid item xs={12}>
              <img
                src="https://dl.openseauserdata.com/cache/originImage/files/b9114130c58db483e2173e7b6f7b31c1.png"
                width="500"
                height="500"
              />
            </Grid>
            <Grid item xs={12}>
              <Typography variant="h4" color="white" align="center">
                {totalSupply + '/' + supply}
              </Typography>
            </Grid>
            <Divider style={{ width: '100%' }} />
            <Grid item xs={12}>
              <Typography color="white" align="center">
                {'PreSale Purchase Limit: ' +
                  preSaleRemaining +
                  '/' +
                  preSaleLimit}
              </Typography>
            </Grid>
            <Divider style={{ width: '100%' }} />
            <Grid item xs={12}>
              <Typography color="white" align="center">
                {'PublicSale Purchase Limit: ' +
                  publicSaleRemaining +
                  '/' +
                  publicSaleLimit}
              </Typography>
            </Grid>
            <Divider style={{ width: '100%' }} />
            <Grid item xs={12}>
              <Typography color="white" align="center">
                {'Price:' + price + ' ETH'}
              </Typography>
            </Grid>
            <Grid item xs={9} pt="5px" pb="20px" pr="5px" pl="25px">
              <LoadingButton
                fullWidth
                onClick={handleClick}
                disabled={!isEligible}
                sx={{ border: '1px solid #ccc' }}
              >
                {isEligible
                  ? 'Mint for ' + (Number(price) * 1000 * amount) / 1000 + 'ETH'
                  : 'You are not eligible'}
              </LoadingButton>
            </Grid>
            <Grid item xs={3} pt="5px" pb="20px" pr="25px">
              <InputText />
            </Grid>
          </Grid>
        </Grid>
      </Grid>
    </Container>
  )
}

export default Mint
