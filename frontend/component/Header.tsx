import { AppBar, Box, Typography } from '@mui/material'
import { ConnectButton } from '@rainbow-me/rainbowkit'

interface MenuLinkProps {
  text: string
  link: string
}
const MenuLink = (props: MenuLinkProps) => {
  return (
    <Typography
      variant="h6"
      component="span"
      sx={{
        paddingLeft: '20px',
        fontFamily: 'serif !important',
        cursor: 'pointer',
      }}
      onClick={() => window.open(props.link, '_blank')}
    >
      {props.text}
    </Typography>
  )
}

const Header = () => {
  return (
    <Box sx={{ flexGrow: 1 }}>
      <AppBar
        enableColorOnDark
        position="fixed"
        color="inherit"
        elevation={0}
        sx={{
          height: 50,
          width: '100%',
          bgcolor: 'rgba(0,0,0,0.87)',
          flexDirection: 'row',
          color: 'white',
          fontFamily: 'serif !important',
        }}
      >
        <Box sx={{ paddingTop: '5px' }}>
          <MenuLink
            text="Discord"
            link="https://discord.com/invite/ekBRMjxCzD"
          />
          <MenuLink text="Twitter" link="https://twitter.com/CryptoMaids" />
          <MenuLink text="WebSite" link="https://cryptomaids.tokyo/home" />
          <MenuLink
            text="TACHIYOMI"
            link="https://cryptomaids.tokyo/tachiyomi"
          />
          <MenuLink
            text="OS"
            link="https://opensea.io/collection/cryptomaids"
          />
          <MenuLink
            text="SHOOTING"
            link="https://cryptomaids-shooting.netlify.app/"
          />
          <MenuLink
            text="NFT STAKING"
            link="https://made-in-maids.cryptomaids.tokyo/"
          />
        </Box>
        <Box sx={{ paddingTop: '5px', flexGrow: 1 }}></Box>
        <Box
          id="connect_button"
          sx={{ paddingTop: '5px', paddingRight: '20px' }}
        >
          <ConnectButton showBalance={false} />
        </Box>
      </AppBar>
    </Box>
  )
}

export default Header
