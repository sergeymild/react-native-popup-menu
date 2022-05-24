import UIKit

open class ContextMenuCell: UITableViewCell {
    
    static let identifier = "ContextMenuCell"

    let titleLabel = UILabel()
    let iconImageView = UIImageView()
    
    weak var contextMenu: ContextMenu?
    weak var tableView: UITableView?
    var item: ContextMenuItem!
    var style : Style? = nil
    
    let separatorView = UIView()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(separatorView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconImageView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        separatorView.frame = .init(
            x: 0,
            y: item.itemHeight,
            width: frame.width,
            height: item.separatorHeight
        )
        
        titleLabel.frame = .init(
            x: item.horizontalPadding,
            y: 0,
            width: frame.width - (item.horizontalPadding * 2) - 16 - item.iconSize,
            height: frame.height - item.separatorHeight
        )
        
        iconImageView.frame = .init(
            x: frame.width - item.horizontalPadding - item.iconSize,
            y: (frame.height - item.iconSize) / 2,
            width: item.iconSize,
            height: item.iconSize
        )
    }

    override open func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.iconImageView.image = nil
    }
    
    open func setup(isLast: Bool) {
        contentView.backgroundColor = style?.backgroundColor ?? .clear
        separatorView.backgroundColor = isLast ? .clear : item.separatorColor
        
        titleLabel.text = item.title
        titleLabel.textColor = item.textColor
        titleLabel.font = item.font
        if item.textAlign == "center" {
            titleLabel.textAlignment = .center
        }
        
        
        iconImageView.image = item.image?.withRenderingMode(.alwaysTemplate)
        iconImageView.isHidden = (item.image == nil)
        iconImageView.tintColor = item.tintColor
    }
    
}
