enum WalletResult {
  addressExisted,
  success
}
class WalletSource {
  static const String inside = 'inside';
  static const String outside = 'outside';
}

enum NetworkTypes {
  mainnet,
  devnet,
  berkeley,
  unknown
}