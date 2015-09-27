---------------------------------------------------------------------------------
-- Title         : 1-bit synchronizer
-- Project       : General Purpose Core
---------------------------------------------------------------------------------
-- File          : SyncBit.vhd
-- Author        : Kurtis Nishimura
---------------------------------------------------------------------------------
-- Description:
-- Simple one-bit synchronizer.
---------------------------------------------------------------------------------

LIBRARY ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
use work.UtilityPkg.all;
library unisim;
use unisim.vcomponents.all;


entity SyncBit is 
   generic (
      SYNC_STAGES_G  : integer := 2;
      RST_POL_G      : sl := '1';
      INIT_STATE_G   : sl := '0';
      GATE_DELAY_G   : time := 1 ns
   );
   port ( 
      -- Clock and reset
      clk         : in  sl;
      rst         : in  sl;
      -- Incoming bit, asynchronous
      asyncBit    : in  sl;
      -- Outgoing bit, synced to clk
      syncBit     : out sl
   ); 
end SyncBit;

-- Define architecture
architecture structural of SyncBit is

   -- Internal Signals
   signal data_sync1 : std_logic;

   -- These attributes will stop Vivado translating the desired flip-flops into an
   -- SRL based shift register.
   attribute ASYNC_REG             : string;
   attribute ASYNC_REG of cdc_reg1 : label is "TRUE";
   attribute ASYNC_REG of cdc_reg2 : label is "TRUE";
 
   -- These attributes will stop timing errors being reported on the target flip-flop during back annotated SDF simulation.
   -- Unfortunately this does not seem to fix timing errors in implementation.
   -- To do this, modify the UCF to add something like:
   -- 
   attribute MSGON             : string;
   attribute MSGON of cdc_reg1 : label is "FALSE";
   attribute MSGON of cdc_reg2 : label is "FALSE";
 
   -- These attributes will stop XST translating the desired flip-flops into an
   -- SRL based shift register.
   attribute shreg_extract             : string;
   attribute shreg_extract of cdc_reg1 : label is "no";
   attribute shreg_extract of cdc_reg2 : label is "no";
  
begin

   cdc_reg1 : FDRE
   generic map (
     INIT => to_bit(INIT_STATE_G)
   )
   port map (
     C    => clk,
     CE   => '1',
     R    => rst,
     D    => asyncBit,
     Q    => data_sync1
   );

   cdc_reg2 : FDRE
   generic map (
     INIT => to_bit(INIT_STATE_G)
   )
   port map (
     C    => clk,
     CE   => '1',
     R    => rst,
     D    => data_sync1,
     Q    => syncBit
   );

end structural;

